#!/bin/bash

# this script clips country polygon from appropriate elevation file
# depending on input parameter [srtm30m, srtm90m, gmted250m]

set -e

country_geojson_filename=$(basename "$1")
country_code="${country_geojson_filename%%.*}"
outdir="data/out/country_extractions/${country_code}/211_elev/"

filetype=$2

mkdir -p $outdir

# clip with country polygon
if [ $filetype = "srtm30m" ]; then
    gdalwarp -of GTIFF -cutline static_data/countries/$1 -crop_to_cutline -overwrite data/mid/srtm30m/srtm.vrt "${outdir}/${country_code}_elev_dem_ras_s0_srtm_pp_elevation30m.tif"
 elif [ $filetype = "srtm90m" ]; then
    gdalwarp -of GTIFF -cutline static_data/countries/$1 -crop_to_cutline -overwrite data/mid/srtm90m/srtm.vrt "${outdir}/${country_code}_elev_dem_ras_s0_srtm_pp_elevation90m.tif"
 elif [ $filetype = "gmted250m" ]; then
    # special naming for gmted250m datasource
    gmted250m_inp=/vsizip/data/in/gmted250m/gmted250m.zip/be75_grd/sta.adf
    gdalwarp -of GTIFF -cutline static_data/countries/$1 -crop_to_cutline -overwrite $gmted250m_inp "${outdir}/${country_code}_elev_dem_ras_s0_gmted2010_pp_elevation250m.tif"
fi

exit 0