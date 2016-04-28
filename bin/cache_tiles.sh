#!/bin/bash

BASE_URL="http://${DOMAIN}"

rm -rf tmp/cache/*
rm -rf public/static_cache/public/tiles/*

# Precache main cities
ruby bin/load_all_tiles.rb "${BASE_URL}/public/tiles/%<zoom>s/%<x>s/%<y>s.json" '14.291153,49.993174,14.659195,50.146546' 13 #osekana praha
ruby bin/load_all_tiles.rb "${BASE_URL}/public/tiles/%<zoom>s/%<x>s/%<y>s.json" '16.484985,49.132981,16.709175,49.260635' 13  #brno
ruby bin/load_all_tiles.rb "${BASE_URL}/public/tiles/%<zoom>s/%<x>s/%<y>s.json" '17.166138,49.542142,17.350159,49.645624' 13  #olomouc
ruby bin/load_all_tiles.rb "${BASE_URL}/public/tiles/%<zoom>s/%<x>s/%<y>s.json" '16.514168,49.289642,16.559486,49.320646' '13' # Kuřim
ruby bin/load_all_tiles.rb "${BASE_URL}/public/tiles/%<zoom>s/%<x>s/%<y>s.json" '16.4007,49.331107,16.446018,49.362085' '13' # Tišnov

# Cache whole CR
./bin/load_all_tiles.rb
