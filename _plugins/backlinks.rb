# Generates backlinks for notes using Obsidian-style wikilinks:
# [[Note Title]]
# [[Note Title|Alias]]
#
# Each note will receive:
#   page.data["backlinks"] = [
#     { "url" => "...", "title" => "...", "excerpt" => "..." }
#   ]

module Jekyll
  class BacklinksGenerator < Generator
    safe true
    priority :low

    # Matches [[target]] or [[target|alias]]
    WIKILINK_REGEX = /\[\[([^\|\]]+)(?:\|([^\]]+))?\]\]/

    def generate(site)
      # All documents in all collections (notes, pages, posts, etc.)
      docs = site.collections.values.flat_map(&:docs) + site.pages

      # Build lookup table: title + slug → doc
      lookup = {}
      docs.each do |doc|
        title = doc.data["title"] || doc.basename_without_ext

        title_key = title.to_s.downcase.strip
        slug_key  = Jekyll::Utils.slugify(title, mode: "default")

        lookup[title_key] = doc
        lookup[slug_key]  = doc
      end

      # Initialize backlinks
      docs.each { |d| d.data["backlinks"] = [] }

      # Scan each document for wikilinks
      docs.each do |doc|
        next unless doc.content

        doc.content.scan(WIKILINK_REGEX).each do |match|
          raw_target = match[0].strip
          target_key_title = raw_target.downcase
          target_key_slug  = Jekyll::Utils.slugify(raw_target, mode: "default")

          # Resolve target
          target_doc =
            lookup[target_key_title] ||
            lookup[target_key_slug]

          next unless target_doc

          # Store backlink
          target_doc.data["backlinks"] << {
            "url"     => doc.url,
            "title"   => doc.data["title"] || doc.basename_without_ext,
            "excerpt" => extract_excerpt(doc)
          }
        end
      end
    end

    private

    def extract_excerpt(doc)
      if doc.data["excerpt"]
        doc.data["excerpt"].to_s
      else
        doc.content.to_s.gsub(/\s+/, " ")[0..200]
      end
    end
  end
end
