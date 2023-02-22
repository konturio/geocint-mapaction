#!/bin/bash

# this script takes as input path to the file (shp, geojson or tif) 
# and creates _ckan.json file, which is used later in the process

set -e

filepath=$1

ckan_dataset_description_json_path="data/out/country_extractions/$(basename $filepath)_ckan.json"
python scripts/build_ckan_dataset_description.py $filepath > $ckan_dataset_description_json_path