#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

root_path = Pathname.new(Dragonfly.app.datastore.root_path)
dest_root_path = root_path + 'only_used'

source_attributes = [
  :text_storage,
  :document_storage
]

Document.find_each do |d|
  source_attributes.each do |source_attribute|
    next if d.send(source_attribute).nil?
    file_path = File.expand_path(d.send(source_attribute).path)

    source = Pathname.new(file_path)
    relative = source.relative_path_from(root_path)

    dest_path = (dest_root_path + relative.dirname)
    dest_path.mkpath
    FileUtils.cp file_path, dest_path

    meta = file_path + '.meta.yml'
    if File.exist?(meta)
      FileUtils.cp meta, dest_path
    end

  end
end
