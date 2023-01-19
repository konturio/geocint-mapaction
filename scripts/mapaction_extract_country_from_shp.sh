#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

input_shp_name=$2
output_name="${3//"{country_code}"/$country_code}"
output_shp_name="$output_name.shp"
output_geojson_name="$output_name.geojson"

mkdir -p "$(dirname $output_shp_name)"
ogr2ogr -clipsrc static_data/countries/$country_geojson_filename -skipfailures $output_geojson_name $input_shp_name

# if number of features = 0 then delete geojson and do not create .shp
res=$(ogrinfo -so -al $output_shp_name | grep "Feature Count:" | sed 's/Feature Count: //g')
if [ $res -eq 0 ]; then
    rm -f $output_geojson_name
else
    ogr2ogr -lco ENCODING=UTF8 -skipfailures $output_shp_name $output_geojson_name
fi

