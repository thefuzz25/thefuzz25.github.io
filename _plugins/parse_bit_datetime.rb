Jekyll::Hooks.register :documents, :pre_render do |doc|
  if doc.collection.label == "bits"
    # Match filenames like 2025-08-10-1031.md
    if doc.basename_without_ext =~ /^(\d{4})-(\d{2})-(\d{2})-(\d{2})(\d{2})$/
      year, month, day, hour, minute = $1, $2, $3, $4, $5
      doc.data['date'] = Time.new(year, month, day, hour, minute)
      doc.data['title'] = nil # Prevents accidental title usage
    end
  end
end
