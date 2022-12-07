#!/bin/bash

OUTDIR=data/out/

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
    output=$(echo "${country_code}_${ma_category}_${ma_theme}_${feature_type}_s0_osm_mm_${ma_tag}" | sed 's/_$//g' | sed -e 's/\(.*\)/\L\1/')
    # generate sql string for ogr, if there are additional columns for layer
    sql=$(psql -t -A -F , -c "select lgudyma.mapaction_export_layer('${country_code}', '${ma_category}', '${ma_theme}', '${ma_tag}', '${feature_type}');")
    ogr2ogr -f "GeoJSON" $OUTDIR$output.geojson PG:"dbname=kontur" -sql "${sql}"
done < <( psql -t -A -F , -c "SELECT country_code, ma_category, ma_theme, feature_type, ma_tag FROM lgudyma.mapaction group by 1,2,3,4,5")