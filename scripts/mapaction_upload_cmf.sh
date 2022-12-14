#!/bin/bash

set -e

country_extraction_path=$1
country_code=$(basename "$country_extraction_path")
echo "country_extraction_path $country_extraction_path"
echo "country_code $country_code"

(cd $country_extraction_path; zip -r "../../cmf/$country_code.zip" .)

aws s3 --endpoint-url=https://storage.yandexcloud.net cp "data/out/cmf/$country_code.zip" "s3://mekillot-backet/akalenik/cmf/$country_code.zip"
