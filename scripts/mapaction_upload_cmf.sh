#!/bin/bash

# TODO: DELETE
# CKAN_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NzEyMTM0OTIsImp0aSI6IkM1ZzBFNUEybEppakJmeEpmYks2eUhoQi04RmwyYTNObFBydWFJQ21RWjFSMjhmM3JQNnprRzdWU0lqY25pVWVPOVNNaVpoWERRNUN3SE8wIn0.PtEaPRU3vEl2lbySff--e8TUjPk3kHZxxzp5M0UhEy0
# akalenik key
CKAN_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NzA0ODY1ODAsImp0aSI6IkFOTGpFRGt6VldQdVJIcGhNWHBZVDJmY2pBZ0d5RHpyR3hqRTJjMDlBNjE2aWx5SV9IQXFnZV9ROXV6VTB0SHBIYVQtcFkwV0xWSkhwck5HIn0._A8Ht4DC4NZZmnwGZbL_zKzX2kbt0xQAvq-NU1U8sR4
CKAN_BASE_URL=https://geocint.kontur.io/ckan
# this script accepts path of country cmf directory as first argument,
# creates zip archives for shp and geojson content and uploads them in s3
# then scripts/build_ckan_cmf_description.py is used to generate ckan
# dataset description from country code which is send to ckan

set -e

country_extraction_path=$1
country_code=$(basename "$country_extraction_path")
echo "country_extraction_path $country_extraction_path"
echo "country_code $country_code"

(cd $country_extraction_path; zip -r "../../cmf/$country_code.shp.zip" . -x \*.geojson)
(cd $country_extraction_path; zip -r "../../cmf/$country_code.geojson.zip" . -i \*.geojson)

# FIXME: s3 bucket name and endpoint url should be specified in env variables
#aws s3 --endpoint-url=https://storage.yandexcloud.net cp "data/out/cmf/$country_code.shp.zip" "s3://mekillot-backet/akalenik/cmf/$country_code.shp.zip"
#aws s3 --endpoint-url=https://storage.yandexcloud.net cp "data/out/cmf/$country_code.geojson.zip" "s3://mekillot-backet/akalenik/cmf/$country_code.geojson.zip"

aws s3 cp "data/out/cmf/$country_code.shp.zip" s3://geodata-eu-central-1-kontur-public/mapaction_dataset/$country_code.shp.zip --acl public-read
aws s3 cp "data/out/cmf/$country_code.geojson.zip" s3://geodata-eu-central-1-kontur-public/mapaction_dataset/$country_code.geojson.zip --acl public-read

ckan_cmf_description_json_path="data/out/"$country_code"_ckan.json"
python3 scripts/build_ckan_cmf_description.py $country_code > $ckan_cmf_description_json_path

set +e
curl -H "Content-Type: application/json" -d @$ckan_cmf_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_create"
curl -H "Content-Type: application/json" -d @$ckan_cmf_description_json_path -H "Authorization: $CKAN_API_KEY" -X POST "$CKAN_BASE_URL/api/3/action/package_update"
set -e
