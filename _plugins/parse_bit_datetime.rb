# _plugins/bit_filename_parser.rb

Jekyll::Hooks.register :documents, :pre_render do |doc|
  if doc.collection.label == "bits"
    if doc.basename_without_ext =~ /^(\d{4})-(\d{2})-(\d{2})-(\d{2})(\d{2})$/
      year, month, day, hour, minute = $1, $2, $3, $4, $5
      t = Time.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
      doc.data['date'] = t
      doc.date = t  # This ensures Liquid uses the correct time
      doc.data['title'] = nil
    end
  end
end
