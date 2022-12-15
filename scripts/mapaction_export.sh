#!/bin/bash

# this script exports mapaction layers from db to json and SHP format
# input: JAM.pbj
# output: files according to naming conventions 
OUTDIR=data/out/mapaction/

base_name=$(basename "$1")
mapaction_table_name="mapaction_${base_name%.*}"
#changing prefix osm_ to mapaction_
#example "osm_tanzania" to "mapaction_tanzania"

# generate layernames for export
# MapAction naming convention 
# geoextent_category_theme_geometry_scale_source_permission[_FreeText]
# geoextent - country_code (tags ->> 'ISO3166-1:alpha3')
# category_theme_geometry - columnms in mapaction table
# scale - s0-3 -for country it is s0
# source - 'osm'
# permission - mm mapaction Only
while IFS="," read -r country_code ma_category ma_theme feature_type ma_tag
do
    # if ma_tag is empty discard last "_" and convert name to lowercase
    output=$(echo "${country_code}_${ma_category}_${ma_theme}_${feature_type}_s4_osm_pp_${ma_tag}" | sed 's/_$//g' | sed -e 's/\(.*\)/\L\1/')
    # generate sql string for ogr, if there are additional columns for layer
    sql=$(psql -t -A -F , -c "select mapaction_data_export('${mapaction_table_name}', '${country_code}', '${ma_category}', '${ma_theme}', '${ma_tag}', '${feature_type}');")
    ogr2ogr -f "ESRI Shapefile" $OUTDIR$output.shp PG:"dbname=gis" -sql "${sql}" -lco ENCODING=UTF8
    rm -f $OUTDIR$output.geojson
    ogr2ogr -f "GeoJSON" $OUTDIR$output.geojson PG:"dbname=gis" -sql "${sql}" -lco WRITE_NAME=NO
done < <( psql -t -A -F , -c "SELECT country_code, ma_category, ma_theme, feature_type, ma_tag FROM ${mapaction_table_name} group by 1,2,3,4,5")
