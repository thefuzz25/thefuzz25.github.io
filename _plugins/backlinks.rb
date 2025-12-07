# frozen_string_literal: true

# Simple backlink generator for Jekyll notes
class BacklinksGenerator < Jekyll::Generator
  safe true
  priority :low

  def generate(site)
    notes = site.collections['notes'].docs
    pages = site.pages
    all_docs = notes + pages

    # Precompute URL → doc map for fast lookup
    url_map = all_docs.map { |d| [d.url, d] }.to_h

    # Build backlink lists
    all_docs.each do |doc|
      doc.data['backlinks'] = []
    end

    all_docs.each do |source|
      all_docs.each do |target|
        next if source == target

        # Detect internal link by final resolved URL (html-extension aware)
        target_url = resolved_url(site, target)

        if source.content.include?(target_url)
          source_title = source.data['title'] || File.basename(source.basename, File.extname(source.basename))
          target.data['backlinks'] << {
            "url" => source.url,
            "title" => source_title,
            "excerpt" => extract_excerpt(source)
          }
        end
      end
    end
  end

  private

  # handle .html extension flag
  def resolved_url(site, doc)
    ext = site.config["use_html_extension"] ? ".html" : ""
    "#{doc.url}#{ext}"
  end

  # Simple excerpt generator
  def extract_excerpt(doc)
    if doc.data['excerpt']
      doc.data['excerpt'].to_s
    else
      doc.content.gsub(/<\/?[^>]*>/, '').split[0..25].join(" ")
    end
  end
end
