#!/bin/sh

#this script uses osmium to extract from planet.pbf
# input: JAM.json
# output: data/in/mapaction/JAM.pbf
base_name=$(basename "$1")
prefix_name=${base_name%.*}
rm -f data/in/mapaction/${prefix_name}.pbf
osmium extract --polygon="$1" data/planet-latest-updated.osm.pbf -o data/in/mapaction/$prefix_name.pbf

