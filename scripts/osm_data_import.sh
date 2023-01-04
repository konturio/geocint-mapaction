#!/bin/bash

set -e

# this script creates osm_{} table in db, imports data and creates index for this table
# input: JAM.pbf
# output: osm_jam table in db
base_name=$(basename "$1")
prefix_name="osm_${base_name%.*}"
input="data/mid/mapaction/${base_name/json/pbf}"
psql -1 -f tables/osm_data_table.sql -v tablename=${prefix_name}
osmium export -c static_data/mapaction_osmium.config.json -f pg $input -v --progress | psql -c -1 "copy $prefix_name from stdin;"
psql -1 -c "create index on $prefix_name using gin (tags);"
