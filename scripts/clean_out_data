#!/bin/bash

# This script deletes all files in data/out directory
# and all tables in postgresql db for country extracts. E.g. mapaction_{country_code} and osm_{country_code}
# Use this script to free up disk space and remove outpud data for countries which are no longer needed.

# delete tables in DB
for country_code in $(find data/out/country_extractions/ -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
do
    psql -1 -c "DROP TABLE IF EXISTS osm_${country_code} cascade;"
    psql -1 -c "DROP TABLE IF EXISTS mapaction_${country_code} cascade;"
done

# delete data/out
rm -rf data/out

mkdir -p data/out