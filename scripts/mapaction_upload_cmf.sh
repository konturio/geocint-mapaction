#!/bin/bash

# this script accepts path of country cmf directory as first argument,
# creates zip archives for shp+tif and geojson+tif content and uploads them in s3
# then scripts/build_ckan_cmf_description.py is used to generate ckan
# dataset description from country code which is send to ckan

set -e

country_extraction_path=$1
country_code=$(basename "$country_extraction_path")
echo "country_extraction_path $country_extraction_path"
echo "country_code $country_code"

(cd $country_extraction_path; zip -r "../../cmf/$country_code""_active_data_shp.zip" . -x \*.geojson)
(cd $country_extraction_path; zip -r "../../cmf/$country_code""_active_data_geojson.zip" . -i \*.geojson \*.txt \*.tif)

# CKAN_DATA_S3_URL=s3://geodata-eu-central-1-kontur-public/mapaction_dataset/
aws s3 cp "data/out/cmf/$country_code""_active_data_shp.zip" $CKAN_DATA_S3_URL$country_code"_active_data_shp.zip" --acl public-read
aws s3 cp "data/out/cmf/$country_code""_active_data_geojson.zip" $CKAN_DATA_S3_URL$country_code"_active_data_geojson.zip" --acl public-read

ckan_cmf_description_json_path="data/out/"$country_code"_ckan.json"
python scripts/build_ckan_cmf_description.py $country_code > $ckan_cmf_description_json_path

set +e
curl -H "Content-Type: application/json" -d @$ckan_cmf_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_create"
curl -H "Content-Type: application/json" -d @$ckan_cmf_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_update"
set -e
