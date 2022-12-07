#!/bin/sh

base_name=$(basename "$1")
prefix_name=${base_name%.*}
osmium export -c static_data/mapaction_osmium.config.json -f pg "$1" -v --progress | psql -c "copy $prefix_name from stdin;"
psql -c "create index on $prefix_name using gin (tags);"
