#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_shp_name=$2
output_name="${3//"{country_code}"/$country_code}"
output_shp_name="$output_name.shp"
output_geojson_name="$output_name.geojson"

# echo "country_geojson_filename $country_geojson_filename"
# echo "input_shp_name $input_shp_name"
# echo "output_shp_name $output_shp_name"

mkdir -p "$(dirname $output_shp_name)"
ogr2ogr -clipsrc static_data/countries/$country_geojson_filename -lco ENCODING=UTF8 -skipfailures $output_shp_name $input_shp_name
ogr2ogr -skipfailures $output_geojson_name $output_shp_name

output_shp_zip_path="data/out/country_extractions/$(basename $output_shp_name).zip"
zip -r -j $output_shp_zip_path "$(dirname $output_shp_name)" -x "*.geojson"

output_geojson_zip_path="data/out/country_extractions/$(basename $output_geojson_name).zip"
zip -r -j $output_geojson_zip_path $output_geojson_name

aws s3 cp $output_shp_zip_path $CKAN_DATA_S3_URL"$(basename $output_shp_zip_path)" --acl public-read
aws s3 cp $output_geojson_zip_path $CKAN_DATA_S3_URL"$(basename $output_geojson_zip_path)" --acl public-read

ckan_dataset_description_json_path=$output_name"_ckan.json"
python scripts/build_ckan_dataset_description.py $output_name > $ckan_dataset_description_json_path

set +e
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_create"
curl -H "Content-Type: application/json" -d @$ckan_dataset_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_update"
set -e
