#!/bin/sh
PSQL_SELECT='psql -q -t -U gis -c'
OUTDIR=data/out/mapaction/

layers=$(${PSQL_SELECT} "SELECT distinct ma_theme FROM mapaction_data;")

for layer in ${layers}; do
    ogr2ogr -f "ESRI Shapefile" ${OUTDIR}map_action_${layer}.shp PG:"dbname=gis" -sql "SELECT * FROM mapaction_data WHERE ma_theme = '${layer}'"
    ogr2ogr -f "GeoJSON" ${OUTDIR}map_action_${layer}.geojson PG:"dbname=gis" -sql "SELECT * FROM mapaction_data WHERE ma_theme = '${layer}'"
done

