#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

fail "Needs ID of document" unless ARGV[0]

d = Document.find(ARGV[0])

file_path = "/tmp/#{d.id}.txt"
if (File.exist?(file_path))
  puts "Budu ukladat, stiskni ENTER"
  STDIN.gets
  d.text_storage = Dragonfly.app.fetch_file(file_path)
  d.save!
else
  puts "zapisuji do #{file_path}"
  File.open(file_path, 'w+') { |f| f.puts d.plain_text }
end
