#!/bin/bash

# this script takes as input path to the file (shp, geojson or tif) 
# zip it and add json with description
# uploads to ckan as separate dataset

set -e

filepath=$1
filetype=$2

output_zip_path="data/out/country_extractions/$(basename $filepath).zip"

if [ $filetype = "shp" ]; then
    # include only related to shp(cpg, dbf, prj, shp, shx) and txt
    zip -r -j $output_zip_path "${filepath%.*}"* -x "*.geojson" "*.tif"
 elif [ $filetype = "geojson" ]; then
    # include only geojson and txt 
    zip -r -j $output_zip_path "${filepath%.*}"* -i "*.geojson" "*.txt"
 elif [ $filetype = "tif" ]; then
    # include only tif
    zip -r -j $output_zip_path "${filepath%.*}"* -i "*.tif"
fi

ckan_dataset_description_json_path="data/out/country_extractions/$(basename $filepath)_ckan.json"

aws s3 cp $output_zip_path $CKAN_DATA_S3_URL$(basename $filepath).zip --acl public-read

set +e
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_create"
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_update"
set -e
