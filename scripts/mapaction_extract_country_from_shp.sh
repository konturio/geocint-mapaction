#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_shp_name=$2
output_name="${3//"{country_code}"/$country_code}"
output_shp_name="$output_name.shp"

echo "country_geojson_filename $country_geojson_filename"
echo "input_shp_name $input_shp_name"
echo "output_shp_name $output_shp_name"

mkdir -p "$(dirname $output_shp_name)"
ogr2ogr -clipsrc static_data/countries/$country_geojson_filename -lco ENCODING=UTF8 -skipfailures $output_shp_name $input_shp_name

output_zip_path="data/out/country_extractions/$(basename $output_name).zip"
zip -r -j $output_zip_path "$(dirname $output_shp_name)"

aws s3 --endpoint-url=https://storage.yandexcloud.net cp $output_zip_path s3://mekillot-backet/akalenik/"$(basename $output_zip_path)"
