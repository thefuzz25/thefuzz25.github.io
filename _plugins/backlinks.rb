# _plugins/backlinks.rb

Jekyll::Hooks.register :site, :post_read do |site|
  # Only process pages inside the notes collection
  notes = site.collections["notes"].docs

  # Clear backlinks
  notes.each do |note|
    note.data["backlinks"] = []
  end

  notes.each do |note|
    content = note.content

    # Find all wikilinks: [[Note]] or [[Note|Alias]]
    wikilinks = content.scan(/\[\[([^\]]+)\]\]/).flatten

    wikilinks.each do |raw|
      target = raw.split("|")[0]  # extract left side before alias

      # slugify so [[My Note]] matches file "my-note.md"
      slug = Jekyll::Utils.slugify(target)

      # find matching note
      linked = notes.find { |n| n.data["slug"] == slug || n.basename_without_ext == slug }

      next unless linked

      # Push backlink to the target note
      linked.data["backlinks"] << {
        "title" => note.data["title"] || File.basename(note.basename, ".*"),
        "url"   => note.url,
        "excerpt" => note.content[0..200]
      }
    end
  end
end
