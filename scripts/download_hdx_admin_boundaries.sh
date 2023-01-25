#!/bin/bash

set -e
shopt -s globstar

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

echo $country_code

ckan_package_json_path=$(mktemp)

if wget -O $ckan_package_json_path "https://data.humdata.org/api/3/action/package_show?id=cod-ab-$country_code"; then
    mkdir -p data/in/mapaction/ocha_admin_boundaries
    mkdir -p data/in/mapaction/ocha_admin_boundaries/$country_code

    for download_url in $(cat $ckan_package_json_path | jq --raw-output '.result.resources[] | .download_url')
    do
        filename=$(basename $download_url)
        file_extension=${filename##*.}
        wget -q -O data/in/mapaction/ocha_admin_boundaries/$filename $download_url
        if [ $file_extension = "zip" ]; then
            unzip -o data/in/mapaction/ocha_admin_boundaries/$filename -d data/in/mapaction/ocha_admin_boundaries/$country_code
        fi
    done

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/**/*adm0*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        display_name=$(cat static_data/admin_level_display_names.json | jq --raw-output ".${country_code}.adm0 // \"adminboundary0\"")
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad0_py_s4_unocha_pp_"$display_name"."$file_extension

        if [ $file_extension = "shp" ]; then
            ogr2ogr "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad0_py_s4_unocha_pp_"$display_name".geojson" $filename
        fi
    done

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/**/*adm1*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        display_name=$(cat static_data/admin_level_display_names.json | jq --raw-output ".${country_code}.adm1 // \"adminboundary1\"")
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad1_py_s4_unocha_pp_"$display_name"."$file_extension

        if [ $file_extension = "shp" ]; then
            ogr2ogr "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad1_py_s4_unocha_pp_"$display_name".geojson" $filename
        fi
    done

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/**/*adm2*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        display_name=$(cat static_data/admin_level_display_names.json | jq --raw-output ".${country_code}.adm2 // \"adminboundary2\"")
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad2_py_s4_unocha_pp_"$display_name"."$file_extension

        if [ $file_extension = "shp" ]; then
            ogr2ogr "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad2_py_s4_unocha_pp_"$display_name".geojson" $filename
        fi
    done
fi
