#!/bin/sh

## rm -f tests/*.pbf
## generating per-country pbf files

for poly in $(ls static_data/mapaction/*.poly); do
  base_name=$(basename ${poly})
  prefix_name="osm_"${base_name%.*}
  osmium extract --polygon=${poly} data/planet-latest-updated.osm.pbf -o data/in/mapaction/$prefix_name.pbf

  echo "${base_name}"
  echo "${prefix_name}"
  echo "${poly}"

done

for pbf in $(ls data/in/mapaction/*.pbf); do
  echo "${pbf}"
  osmium export -c osmium.config.json -f pg ${pbf} -v --progress | psql -c "copy $prefix_name from stdin;"

done
