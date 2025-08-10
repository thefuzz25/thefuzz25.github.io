# _plugins/bit_filename_parser.rb

Jekyll::Hooks.register :documents, :pre_render do |doc|
  if doc.collection.label == "bits"
    # Match filenames like 2025-08-10-1031.md
    if doc.basename_without_ext =~ /^(\d{4})-(\d{2})-(\d{2})-(\d{2})(\d{2})$/
      year, month, day, hour, minute = $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i

      # Force local time so Jekyll doesn't convert to UTC midnight
      local_time = Time.local(year, month, day, hour, minute)

      doc.data['date'] = local_time
      doc.data['title'] = nil # Prevent accidental title usage
    end
  end
end
