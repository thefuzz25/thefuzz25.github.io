Jekyll::Hooks.register :documents, :pre_render do |doc|
  if doc.collection.label == "bits"
    # Use current local time
    doc.data['date'] = Time.now
    doc.data['title'] = nil # Prevent accidental title usage
  end
end
