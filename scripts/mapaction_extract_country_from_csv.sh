#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_csv_name=$2
output_name="${3//"{country_code}"/$country_code}"
output_shp_name="$output_name.shp"
output_geojson_name="$output_name.geojson"

mkdir -p "$(dirname $output_shp_name)"
ogr2ogr -s_srs EPSG:4326 -t_srs EPSG:3857 -oo X_POSSIBLE_NAMES=lon* -oo Y_POSSIBLE_NAMES=lat* -lco ENCODING=UTF8 -clipsrc static_data/countries/$country_geojson_filename  -f "ESRI Shapefile" $output_shp_name $input_csv_name
ogr2ogr -skipfailures $output_geojson_name $output_shp_name

output_shp_zip_path="data/out/country_extractions/$(basename $output_shp_name).zip"
zip -r -j $output_shp_zip_path "$(dirname $output_shp_name)" -x "*.geojson"

output_geojson_zip_path="data/out/country_extractions/$(basename $output_geojson_name).zip"
zip -r -j $output_geojson_zip_path $output_geojson_name

# FIXME: s3 bucket name and endpoint url should be specified in env variables
aws s3 --endpoint-url=https://storage.yandexcloud.net cp $output_shp_zip_path s3://mekillot-backet/akalenik/"$(basename $output_shp_zip_path)"
aws s3 --endpoint-url=https://storage.yandexcloud.net cp $output_geojson_zip_path s3://mekillot-backet/akalenik/"$(basename $output_geojson_zip_path)"
