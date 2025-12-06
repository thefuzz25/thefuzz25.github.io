# _plugins/wikilinks_and_backlinks.rb

module Jekyll
  class WikilinksGenerator < Generator
    safe true
    priority :low

    WIKILINK = /\[\[([^\|\]]+)(?:\|([^\]]+))?\]\]/  # [[Note]] or [[Note|Alias]]

    def generate(site)
      notes = site.collections["notes"]&.docs || []
      index = {}

      # Build title→doc and slug→doc index
      notes.each do |n|
        title = (n.data["title"] || n.basename_without_ext).to_s
        slug  = Utils.slugify(title)
        index[title.downcase] = n
        index[slug] = n
      end

      # Initialize backlinks
      notes.each { |n| n.data["backlinks"] = [] }

      notes.each do |note|
        content = note.content.dup

        content.scan(WIKILINK).each do |raw_title, alias_text|
          key = raw_title.downcase
          linked = index[key]
          next if linked.nil?

          url = linked.url
          label = alias_text || linked.data["title"] || linked.basename_without_ext

          # Replace only in rendered output, not source
          note.content = note.content.gsub("[[#{raw_title}#{alias_text ? '|' + alias_text : ''}]]",
            "<a class=\"internal-link\" href=\"#{url}\">#{label}</a>"
          )

          # Populate backlinks
          linked.data["backlinks"] << {
            "url" => note.url,
            "title" => note.data["title"] || note.basename_without_ext,
            "excerpt" => note.content[0..100]
          }
        end
      end
    end
  end
end
