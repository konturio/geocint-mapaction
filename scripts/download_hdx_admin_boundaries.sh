#!/bin/bash

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

echo $country_code

ckan_package_json_path=$(mktemp)

if wget -O $ckan_package_json_path "https://data.humdata.org/api/3/action/package_show?id=cod-ab-$country_code"; then
    shp_download_url=$(cat $ckan_package_json_path | jq --raw-output '.result.resources[] | .download_url' | grep --ignore-case "shp")
    shp_filename=$(basename $shp_download_url)

    mkdir -p data/in/mapaction/ocha_admin_boundaries
    wget -O data/in/mapaction/ocha_admin_boundaries/$shp_filename $shp_download_url

    mkdir -p data/in/mapaction/ocha_admin_boundaries/$country_code
    unzip data/in/mapaction/ocha_admin_boundaries/$shp_filename -d data/in/mapaction/ocha_admin_boundaries/$country_code

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/*adm0*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad0_py_s4_unocha_pp_adminboundary0."$file_extension
    done

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/*adm1*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad1_py_s4_unocha_pp_adminboundary1."$file_extension
    done

    for filename in data/in/mapaction/ocha_admin_boundaries/$country_code/*adm2*
    do
        file_extension=${filename##*.}
        mkdir -p "data/out/country_extractions/"$country_code"/202_admn/"
        cp $filename "data/out/country_extractions/"$country_code"/202_admn/"$country_code"_admn_ad2_py_s4_unocha_pp_adminboundary2."$file_extension
    done
fi
