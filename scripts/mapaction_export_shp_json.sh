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
    output="${country_code}_${ma_category}_${ma_theme}_${feature_type}_s1_osm_mm_${ma_tag}"
    ogr2ogr -f "GeoJSON" $OUTDIR$output.geojson PG:"dbname=kontur" -sql "SELECT * FROM lgudyma.mapaction WHERE (country_code, ma_category, ma_theme, feature_type) = ('$country_code','$ma_category','$ma_theme','$feature_type')"
done < <( psql -t -A -F , -c "SELECT country_code, ma_category, ma_theme, feature_type, ma_tag FROM lgudyma.mapaction group by 1,2,3,4,5")