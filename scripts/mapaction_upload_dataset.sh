#!/bin/bash

set -e

shp_path=$1
geojson_path="${shp_path%.*}.geojson"

output_shp_zip_path="data/out/country_extractions/$(basename $shp_path).zip"
zip -r -j $output_shp_zip_path "${shp_path%.*}"* -x "*.geojson"

output_geojson_zip_path="data/out/country_extractions/$(basename $geojson_path).zip"
zip -r -j $output_geojson_zip_path "${shp_path%.*}.geojson"

echo "output_shp_zip_path $output_shp_zip_path"
echo "output_geojson_zip_path $output_geojson_zip_path"

ckan_dataset_description_json_path="data/out/country_extractions/$(basename $shp_path)_ckan.json"
echo "ckan_dataset_description_json_path $ckan_dataset_description_json_path"

python scripts/build_ckan_dataset_description.py $shp_path > $ckan_dataset_description_json_path

aws s3 cp $output_shp_zip_path $CKAN_DATA_S3_URL$output_shp_zip_path --acl public-read
aws s3 cp $output_geojson_zip_path $CKAN_DATA_S3_URL$output_geojson_zip_path --acl public-read

set +e
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_create"
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_update"
set -e
