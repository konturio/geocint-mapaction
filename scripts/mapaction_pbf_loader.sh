#!/bin/sh

rm -f data/in/mapaction/*.pbf
## generating per-country pbf files

for poly in $(ls static_data/mapaction/mapaction_poly_files/*.poly); do
  base_name=$(basename ${poly})
  prefix_name="osm_"${base_name%.*}
  osmium extract --polygon=${poly} data/planet-latest-updated.osm.pbf -o data/in/mapaction/$prefix_name.pbf
  psql -f scripts/mapaction_pbf_loader.sql -v tablename=${prefix_name}
done
