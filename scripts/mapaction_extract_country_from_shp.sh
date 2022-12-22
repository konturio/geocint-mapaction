#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_shp_name=$2
output_name="${3//"{country_code}"/$country_code}"
output_shp_name="$output_name.shp"
output_geojson_name="$output_name.geojson"

mkdir -p "$(dirname $output_shp_name)"
ogr2ogr -clipsrc static_data/countries/$country_geojson_filename -lco ENCODING=UTF8 -skipfailures $output_shp_name $input_shp_name
ogr2ogr -skipfailures $output_geojson_name $output_shp_name
