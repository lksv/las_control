#!/bin/bash

curl http://localhost:3000/local_administration_units > /dev/null
curl http://localhost:3000/local_administration_units/options.json?query=Brno&per=20&page=1&_=1458290270986 > /dev/null
ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' '14.291153,49.993174,14.659195,50.146546'  #osekana praha
ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' '16.484985,49.132981,16.709175,49.260635'  #brno
ruby bin/load_all_tiles.rb 'http://localhost:3000/tiles/%<zoom>s/%<x>s/%<y>s.json' '17.166138,49.542142,17.350159,49.645624'  #olomouc
