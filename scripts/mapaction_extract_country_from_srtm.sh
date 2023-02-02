#!/bin/bash

# this script clips country polygon from data/mid/srtm/srtm.vrt

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"

# clip with country polygon
gdalwarp -of GTIFF -cutline $1 -crop_to_cutline -overwrite data/mid/srtm/srtm.vrt "data/out/country_extractions/${country_code}/211_elev/${country_code}_elev_dem_ras_s0_srtm_pp_elevation30m.tif"

exit 0