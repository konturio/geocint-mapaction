#!/bin/bash

# this script downloads all srtm zipped tiles
# fixes some zip archives with bad filenames inside
# and generates virtual raster layer

download_list=static_data/srtm_urls.csv
srtm_zip_dir=data/in/srtm
srtm_vrt_dir=data/mid/srtm

mkdir -p $srtm_zip_dir
mkdir -p $srtm_vrt_dir

# takes about 8-9 hours to download, errors while downloading will be logged into _download-errors.log
# 14163 files, 97G
wget -P $srtm_zip_dir -i $download_list -nv --rejected-log=$srtm_zip_dir/_download-errors.log -nc

# if some files were not downloaded - stop the script
if [ -f $srtm_zip_dir/_download-errors.log ]; then exit 1; fi

# in some zip files there are bad filenames, fixing them
# this list was collected during development
bad_zips="N37E051.SRTMGL1.hgt.zip N37E052.SRTMGL1.hgt.zip N38E050.SRTMGL1.hgt.zip N38E051.SRTMGL1.hgt.zip N38E052.SRTMGL1.hgt.zip N39E050.SRTMGL1.hgt.zip N39E051.SRTMGL1.hgt.zip N40E051.SRTMGL1.hgt.zip N41E050.SRTMGL1.hgt.zip N41E051.SRTMGL1.hgt.zip N42E049.SRTMGL1.hgt.zip N42E050.SRTMGL1.hgt.zip N43E048.SRTMGL1.hgt.zip N43E049.SRTMGL1.hgt.zip N44E048.SRTMGL1.hgt.zip N44E049.SRTMGL1.hgt.zip N47W087.SRTMGL1.hgt.zip"

ch1=$'\100' # @
ch2=$'\012' # \n
for f in $bad_zips
do 
    # echo "$ch1 ${f:0:19}$ch2$ch1=${f:0:7}.hgt"
    # rename files inside zip without unzipping
    zipnote -w $srtm_zip_dir/$f <<< "$ch1 ${f:0:19}$ch2$ch1=${f:0:7}.hgt"
done

# generate list of files to use them in virtual raster layer
rm -f $srtm_zip_dir/_list_files.txt
for f in $srtm_zip_dir/*; do echo -e "/vsizip/${f}/${f:14:7}.hgt" >> $srtm_zip_dir/_list_files.txt; done

# generate virtual raster layer
gdalbuildvrt -overwrite $srtm_vrt_dir/srtm.vrt -input_file_list $srtm_zip_dir/_list_files.txt