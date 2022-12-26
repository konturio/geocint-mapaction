#!/bin/bash

# this script exports mapaction layers from db to json and SHP format
# input: JAM.pbj
# output: files according to naming conventions 

#changing prefix osm_ to mapaction_
#example "osm_jam" to "mapaction_jam"
base_name=$(basename "$1")
mapaction_table_name="mapaction_${base_name%.*}"
OUTDIR="data/out/country_extractions/${base_name%.*}"

# generate directories for export
while IFS="," read -r dir_name
do
    mkdir -p $OUTDIR/$dir_name
done < <( psql -t -A -F , -c "select a.dir_name from mapaction_directories as a, (select ma_category from ${mapaction_table_name} group by 1) as b where dir_name ~* ma_category")

# generate layernames for export
# MapAction naming convention 
# geoextent_category_theme_geometry_scale_source_permission[_FreeText]
# geoextent - country_code (tags ->> 'ISO3166-1:alpha3')
# category_theme_geometry - columnms in mapaction table
# scale - s4 large scale mapping
# source - 'osm'
# permission - pp public dataset
while IFS="," read -r country_code ma_category ma_theme feature_type ma_tag dir_name
do
    # if ma_tag is empty discard last "_" and convert name to lowercase
    output=$(echo "${country_code}_${ma_category}_${ma_theme}_${feature_type}_s4_osm_pp_${ma_tag}" | sed 's/_$//g' | sed -e 's/\(.*\)/\L\1/')
    # $dir_name is directory according to category
    # generate sql string for ogr, if there are additional columns for layer
    sql=$(psql -t -A -F , -c "select mapaction_data_export('${mapaction_table_name}', '${country_code}', '${ma_category}', '${ma_theme}', '${ma_tag}', '${feature_type}');")
    ogr2ogr -f "ESRI Shapefile" $OUTDIR/$dir_name/$output.shp PG:"dbname=gis" -sql "${sql}" -lco ENCODING=UTF8
    rm -f $OUTDIR/$dir_name/$output.geojson
    ogr2ogr -f "GeoJSON" $OUTDIR/$dir_name/$output.geojson PG:"dbname=gis" -sql "${sql}" -lco WRITE_NAME=NO
done < <( psql -t -A -F , -c "SELECT country_code, ma_category, ma_theme, feature_type, ma_tag, dir_name FROM ${mapaction_table_name}, mapaction_directories where dir_name ~* ma_category group by 1,2,3,4,5,6")

# delete empty directories if exists
find $OUTDIR -type d -empty -delete