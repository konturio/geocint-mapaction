#!/bin/bash

# this script creates osm_{} table in db, imports data and creates index for this table
# input: JAM.pbf
# output: osm_jam table in db
base_name=$(basename "$1")
prefix_name="osm_${base_name%.*}"
psql -f tables/osm_data_table.sql -v tablename=${prefix_name}
osmium export -c static_data/mapaction_osmium.config.json -f pg "$1" -v --progress | psql -c "copy $prefix_name from stdin;"
psql -c "create index on $prefix_name using gin (tags);"
