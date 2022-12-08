#!/bin/sh

base_name=$(basename "$1")
prefix_name=${base_name%.*} 
#changing prefix osm_ to mapaction_
#example "osm_tanzania" to "mapaction_tanzania"
mapaction_table_name=${prefix_name/osm_/mapcation_} 
psql -f tables/mapaction_data_table.sql -v tablename=${prefix_name}
psql -f tables/mapaction_data_filler.sql -v osm_table=${prefix_name} -v ma_table=${mapaction_table_name}
