#!/bin/sh

for pbf in $(ls data/in/mapaction/*.pbf); do
  base_name=$(basename ${pbf})
  prefix_name=${base_name%.*}
  psql -f tables/mapaction_data_filler.sql -v tablename=${prefix_name}
done

