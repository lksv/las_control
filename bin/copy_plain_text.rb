#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

dest_dir = Pathname.new("/bigStorage/otevrenebrno/s3/only_plain_text")
root_path = Pathname.new(Dragonfly.app.datastore.root_path)

STDERR.puts "postupujte:"
STDERR.puts "ruby #{$0} > /tmp/plain_text_files.txt"
STDERR.puts "cd #{root_path}"
STDERR.puts "tar cvjf copy_plain_text.tar.bz2 -T /tmp/plain_text_files.txt"
STDERR.puts "# ...on the destination server:"
STDERR.puts "  1. findout root_path (Dragonfly.app.datastore.root_path)"
STDERR.puts "  2. cd root_path"
STDERR.puts "  3. tar xjf copy_plain_text.tar.bz2"

source_attribute = ARGV[0] ? ARGV[0].to_sym : :text_storage

Document.find_each do |d|
  next if d.send(source_attribute).nil?
  source = Pathname.new(File.expand_path(d.send(source_attribute).path))
  relative = source.relative_path_from(root_path)
  puts relative
end
