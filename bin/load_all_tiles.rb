#!/usr/bin/env ruby

# list all tiles from epgs:5514
# WGS84 bounds:
#   12.09 47.73
#   22.56 51.0
# but I use only CR, e.g.:
#   12.09 47.73
#   19 51.0

#usage:
#    ruby bin/load_all_tiles.rb 'http://luksrock.cz:3000/tiles/\%<zoom>s/\%<x>s/\%<y>s.json'
#    ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' '14.291153,49.993174,14.659195,50.146546'  #osekana praha
#    ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' '16.484985,49.132981,16.709175,49.260635'  #brno
#    ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' 17.166138,49.542142,17.350159,49.645624  #olomouc


# see how to convert WSG84 to tile http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
def get_tile_number(lat, lng, zoom)
  n = 2.0 ** zoom
  x = ((lng + 180.0) / 360.0 * n).to_i
  lat_rad = lat/180 * Math::PI
  y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
  {:x => x, :y =>y}
end

BOUNDS = ARGV[1] ? ARGV[1].split(',').map(&:to_f) : nil
MIN_BOUNDS = BOUNDS ? [BOUNDS[1], BOUNDS[0]] : [47.73, 12.09]
MAX_BOUNDS = BOUNDS ? [BOUNDS[3], BOUNDS[2]] : [51.06, 19]
#MAX_BOUNDS = [51.06, 22.56] with Slovak

puts "Caching bounds: #{MIN_BOUNDS} - #{MAX_BOUNDS}"

# EPGS-5514: 12.09 47.73, 22.56 51.06
# You can easily select bounding box here: http://boundingbox.klokantech.com/
# (select CSV export)
# 13.2007,48.7381,16.2048,50.8441 # Cechy (not all)
# 16.12,48.8069,18.457,50.11 # Morava
#
# 14.2472,49.9428,14.7059,50.1817 # Praha
# 14.291153,49.993174,14.659195,50.146546 #Osekla praha
# 16.484985,49.132981,16.709175,49.260635 # Brno
# 17.166138,49.542142,17.350159,49.645624 # Olomouc
# 16.514168,49.289642,16.559486,49.320646 # Kuřim
# 16.4007,49.331107,16.446018,49.362085 # Tišnov

# see http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
def list_zoom(zoom)
  min = get_tile_number(MIN_BOUNDS[0], MIN_BOUNDS[1], zoom)
  max = get_tile_number(MAX_BOUNDS[0], MAX_BOUNDS[1], zoom)
  (min[:x]..max[:x]).map do |x|
    (max[:y]..min[:y]).map do |y|
      { x: x, y: y, zoom: zoom }
    end
  end.flatten
end

def cache_zoom(url_base, zoom)
  list = list_zoom(zoom)

  require 'open-uri'
  list.each_with_index do |tile, idx|
    url = sprintf(url_base, tile)
    tile_size = open(url).gets.size
    sleep 0.01
    puts "#{idx}/#{list.size}. #{url} => #{tile_size}"
  end
end

url = ARGV[0] || 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json'
p url

layers = (ARGV[2] || '15,16').split(',').map(&:to_i)
layers.each do |zoom|
  puts "Caching zoom #{zoom}"
  cache_zoom(url, zoom)
end
