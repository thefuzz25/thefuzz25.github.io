# _plugins/bidirectional_links.rb
#
# Robust backlinks + wikilink helper for Jekyll notes.
# - Populates each note's `data['backlinks']` with an array of hashes:
#     { "url" => ..., "title" => ..., "excerpt" => ... }
# - Works with: [[Note]], [[Note|Alias]], converted <a href="..."> links,
#   index.html vs folder permalinks, and site.baseurl prefixes.
#
# Place this file in _plugins/ and commit. Requires Jekyll run via GitHub Actions
# (GitHub Pages' hosted build blocks custom plugins).

module Jekyll
  class BidirectionalLinksGenerator < Generator
    safe true
    priority :low

    WIKILINK_CAPTURE = /\[\[([^\|\]]+)(?:\|([^\]]+))?\]\]/ # [[Title]] or [[Title|Alias]]

    def generate(site)
      base = (site.baseurl || "").to_s.chomp('/')
      link_extension = site.config['use_html_extension'] ? '.html' : ''

      notes_coll = site.collections['notes']
      return unless notes_coll # nothing to do if no notes collection

      notes = notes_coll.docs

      # Helper to get a stable id/title/slug for a note
      notes_index = {}
      notes.each do |n|
        title = (n.data['title'] || safe_basename(n)).to_s
        slug  = Jekyll::Utils.slugify(title, mode: 'default')
        notes_index[title.downcase] = n
        notes_index[slug] = n
      end

      # initialize backlinks
      notes.each { |n| n.data['backlinks'] = [] }

      # Precompute a map from note -> possible URL variants to search for in other notes
      url_variants = {}
      notes.each do |n|
        url = n.url.to_s
        # normalize ensure leading slash
        url = '/' + url.sub(/^\//, '')
        # variants to catch different permalink outputs
        variants = []
        variants << url
        variants << url.chomp('/') + '.html'    # /note -> /note.html
        variants << (url.end_with?('.html') ? url.sub(/\.html$/, '/') : url + 'index.html') # /note.html -> /note/ or index.html
        variants << url.gsub(/index\.html$/, '') # /note/index.html -> /note/
        # site baseurl prefixed
        variants_with_base = variants.map { |v| base.empty? ? v : "#{base}#{v}" }
        url_variants[n] = (variants + variants_with_base).uniq
      end

      # Now, for each note A, scan other notes B for:
      #  - href="...variant..."
      #  - raw wikilink [[Title]] or [[Title|Alias]] referring to A (by title or slug)
      notes.each do |target_note|
        notes.each do |source_note|
          next if source_note == target_note

          found = false
          content = (source_note.content || "")

          # 1) Check for href-based backlinks
          url_variants[target_note].each do |variant|
            # search for href="...variant..." or href='...variant...' or plain occurrence
            if content.include?(variant) || content.match?(Regexp.new(Regexp.escape("href=\"#{variant}")) ) || content.match?(Regexp.new(Regexp.escape("href='#{variant}'")) )
              found = true
              break
            end
          end
          next if found

          # 2) Check for raw wikilink pointing to target by title or slug:
          title = (target_note.data['title'] || safe_basename(target_note)).to_s
          slug  = Jekyll::Utils.slugify(title, mode: 'default')

          # Create regex to match [[title]] or [[title|alias]], case-insensitive
          wikilink_title_re = Regexp.new("\\[\\[\\s*#{Regexp.escape(title)}(?:\\|[^\\]]+)?\\s*\\]\\]", Regexp::IGNORECASE)
          wikilink_slug_re  = Regexp.new("\\[\\[\\s*#{Regexp.escape(slug)}(?:\\|[^\\]]+)?\\s*\\]\\]", Regexp::IGNORECASE)

          if content.match?(wikilink_title_re) || content.match?(wikilink_slug_re)
            found = true
          end

          next unless found

          # if found, push backlink entry into target_note.data['backlinks']
          target_note.data['backlinks'] << {
            "url" => source_note.url,
            "title" => (source_note.data['title'] || safe_basename(source_note)),
            "excerpt" => excerpt_from(source_note)
          }
        end
      end

      # Optionally write a graph file (like your previous plugin did)
      graph_nodes = []
      graph_edges = []
      notes.each do |n|
        next if n.path && n.path.include?('_notes/index.html')
        graph_nodes << { id: note_id(n), path: "#{base}#{n.url}", label: n.data['title'] || safe_basename(n) }
        (n.data['backlinks'] || []).each do |b|
          # find source note id (best-effort)
          src = notes.find { |x| x.url == b['url'] }
          graph_edges << { source: note_id(src || n), target: note_id(n) } if src
        end
      end

      begin
        File.write('_includes/notes_graph.json', JSON.dump({ edges: graph_edges, nodes: graph_nodes }))
      rescue => e
        Jekyll.logger.warn "BidirectionalLinks:", "Could not write notes_graph.json (#{e.message})"
      end
    end

    private

    def safe_basename(doc)
      if doc.respond_to?(:basename_without_ext)
        doc.basename_without_ext
      else
        # fallback for Page objects (e.g., styles.scss)
        File.basename(doc.relative_path || doc.path || "", ".*")
      end
    end

    def excerpt_from(doc)
      if doc.data && doc.data['excerpt']
        doc.data['excerpt'].to_s
      else
        # collapse whitespace and truncate
        doc.content.to_s.gsub(/\s+/, ' ')[0..200]
      end
    end

    def note_id(doc)
      return "" unless doc
      ((doc.data['title'] || safe_basename(doc)).to_s.bytes.join)
    end
  end
end
