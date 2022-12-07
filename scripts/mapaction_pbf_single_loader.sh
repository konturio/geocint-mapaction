#!/bin/sh

base_name=$(basename "$1")
prefix_name="osm_"${base_name%.*}
rm -f data/in/mapaction/${prefix_name}.pbf
osmium extract --polygon="$1" data/planet-latest-updated.osm.pbf -o data/in/mapaction/$prefix_name.pbf
psql -f scripts/mapaction_pbf_loader.sql -v tablename=${prefix_name}
