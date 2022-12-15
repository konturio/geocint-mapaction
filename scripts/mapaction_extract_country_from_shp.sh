#!/bin/bash

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_shp_name=$2
output_shp_name="${3//"{country_code}"/$country_code}"

echo "country_geojson_filename $country_geojson_filename"
echo "input_shp_name $input_shp_name"
echo "output_shp_name $output_shp_name"

mkdir -p "$(dirname $output_shp_name)"

ogr2ogr -clipsrc static_data/countries/$country_geojson_filename -lco ENCODING=UTF8 -skipfailures $output_shp_name $input_shp_name


