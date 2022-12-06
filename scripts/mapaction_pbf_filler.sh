#!/bin/sh

for pbf in $(ls data/in/mapaction/*.pbf); do
  base_name=$(basename ${pbf})
  prefix_name=${base_name%.*}
  echo "${pbf}"
  osmium export -c static_data/mapaction_osmium.config.json -f pg ${pbf} -v --progress | psql -c "copy $prefix_name from stdin;"
  psql -c "create index on $prefix_name using gin (tags);"
done

