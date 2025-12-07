# frozen_string_literal: true
class BidirectionalLinksGenerator < Jekyll::Generator
  def generate(site)
    all_notes = site.collections['notes'].docs
    all_pages = site.pages
    all_docs  = all_notes + all_pages

    link_extension = !!site.config["use_html_extension"] ? '.html' : ''

    #
    # ----------------------------------------------------------
    # 1. Convert Wiki-style links ([[...]]) into <a> tags
    # ----------------------------------------------------------
    #
    all_docs.each do |current_note|
      all_docs.each do |note_potentially_linked_to|
        # Detect note by filename (basename) or title
        note_title_regexp_pattern = Regexp.escape(
          File.basename(
            note_potentially_linked_to.basename,
            File.extname(note_potentially_linked_to.basename)
          )
        ).gsub('\_', '[ _]').gsub('\-', '[ -]').capitalize

        title_from_data = note_potentially_linked_to.data['title']
        title_from_data = Regexp.escape(title_from_data) if title_from_data

        new_href = "#{site.baseurl}#{note_potentially_linked_to.url}#{link_extension}"
        anchor_tag = "<a class='internal-link' href='#{new_href}'>\\1</a>"

        # [[Title|Label]]
        current_note.content.gsub!(
          /\[\[#{note_title_regexp_pattern}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # [[filename|Label]]
        current_note.content.gsub!(
          /\[\[#{title_from_data}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # [[Title]]
        current_note.content.gsub!(
          /\[\[(#{title_from_data})\]\]/i,
          anchor_tag
        )

        # [[filename]]
        current_note.content.gsub!(
          /\[\[(#{note_title_regexp_pattern})\]\]/i,
          anchor_tag
        )
      end

      # Any remaining [[...]] now point to nonexisting notes → mark invalid
      current_note.content = current_note.content.gsub(
        /\[\[([^\]]+)\]\]/i,
        <<~HTML.delete("\n")
          <span title='There is no note that matches this link.' class='invalid-link'>
            <span class='invalid-link-brackets'>[[</span>
            \\1
            <span class='invalid-link-brackets'>]]</span></span>
        HTML
      )
    end

    #
    # ----------------------------------------------------------
    # 2. Backlink generation
    # ----------------------------------------------------------
    #
    all_notes.each do |current_note|
      expected_href = "#{site.baseurl}#{current_note.url}#{link_extension}"

      backlinks = all_notes.select do |other|
        next false if other.url == current_note.url

        # Detect the HTML inserted earlier
        other.content.include?("href='#{expected_href}'") ||
        other.content.include?("href=\"#{expected_href}\"")
      end

      # Store backlinks as clean objects: { title, url }
      current_note.data['backlinks'] = backlinks.map do |n|
        {
          'title' => n.data['title'],
          'url'   => "#{site.baseurl}#{n.url}#{link_extension}"
        }
      end
    end
  end
end
