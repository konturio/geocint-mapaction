#!/bin/sh

base_name=$(basename "$1")
prefix_name=${base_name%.*}
psql -f tables/mapaction_data_filler.sql -v tablename=${prefix_name}
