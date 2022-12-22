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
