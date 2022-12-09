#!/bin/bash

# this scirpt create mapaction_[] table and populates it with data from osm_[] table
# input: JAM.pbf
# output: mapaction_jam table
base_name=$(basename "$1")
osm_table_name="osm_${base_name%.*}"
<<<<<<< HEAD
mapaction_table_name="${osm_table_name/osm_/mapaction_}"
=======
mapaction_table_name="${osm_table_name/osm_/mapcation_}"
>>>>>>> dc5968d (13288-create-dataset-export-per-country-both-json-and-shp)
psql -f tables/mapaction_data_table.sql -v osm_table=${osm_table_name} -v ma_table=${mapaction_table_name}
