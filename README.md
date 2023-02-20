# geocint-mapaction

This repository contains opensource geodata ETL/CI/CD pipeline developed by [Kontur](https://www.kontur.io/about/) for [MapAction](http://mapaction.org). 
It is based on Kontur Geocint technology.

## What does this pipeline do?

This pipeline downloads data from various sources, including OpenStreetMap, HDX and others, and produces geospatial datasets, in form of geojsons and ESRI shapefiles, which are uploaded to S3 compatible storage and to CKAN.

## Installation and configuration

In order to make it running, you need two other repositories:

* https://github.com/konturio/geocint-runner
* https://github.com/konturio/geocint-openstreetmap

For more information on geocint installation and basic configuration please see [Geocint readme](https://github.com/konturio/geocint-runner/blob/main/README.md) and [Geocint documentation](https://github.com/konturio/geocint-runner/blob/main/DOCUMENTATION.md).

There are 2 things that are needed to be configured for this pipeline specifically:
1. You need to create [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) compartible storage.
2. You need to create you own [CKAN](https://ckan.org/) installation.

For S3 storage you can use Amazon services or any other cloud/hosting provider who provides S3 compartible storage.  For S3 storage creation please refer to [Amazon S3 documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html) or documentation of your hosting provider.

For CKAN installation an configuration please refer to CKAN [Maintainer’s guide](https://docs.ckan.org/en/2.9/maintaining/index.html). 

The following sections describe how to specify credentials for S3 storage and CKAN for the pipeline.
### Setting up AWS credentials

1. `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` are specified in environment variables. Please check this [manual](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) for more informarmation or use `aws configure`.

### CKAN configuration

1. `CKAN_BASE_URL` in `config.inc.sh` should be set to url of your CKAN installation, for example `https://ckan.test.io/ckan`.
2. `CKAN_API_KEY` in `config.in.sh` should be set to API key manually generated from CKAN UI (User Profile > Manage > API tokens). You can find more information in CKAN [documentation](https://docs.ckan.org/en/2.9/api/#authentication-and-api-tokens).
3. In `config.inc.sh` variable `CKAN_DATA_S3_URL` should be specified to path in S3 where you expect datasets to be uploaded, for example `s3://geodata-eu-central-1-kontur-public/mapaction_dataset/` and variable `CKAN_DATA_URL` should point at the same path in S3 as `CKAN_DATA_S3_URL` but using http protocol, for example `https://geodata-eu-central-1-kontur-public.s3.amazonaws.com/mapaction_dataset/`.

Note: S3 paths should be specified with trailing slash /. Variable values should be specified WITHOUT quotes. 

EXAMPLE

    # CKAN Configuration
    # Url of your CKAN instance 
    CKAN_BASE_URL=https://ckan.test.io/ckan

    # API KEY of your CKAN user. Make sure it is added as editor to a proper organization
    CKAN_API_KEY=aaaaaaaaaabbbbbbbbbbbbbbbcccccccc                                              

    # S3 path to you basket and folder, with trailing "/"
    CKAN_DATA_S3_URL=s3://geodata-eu-central-1-kontur-public/mapaction_dataset/ 

    # path to your files on S3 via http(s) protocol, with trailing "/"                 
    CKAN_DATA_URL=https://geodata-eu-central-1-kontur-public.s3.amazonaws.com/mapaction_dataset/ 

### geocint-mapaction configuration

1. To generate data for a country there should be a json file with country boundaries in the directory `static_data/countries`.
Currently there are 25 countries from MapAction priority country linst in this directory. 
To add another countries you can copy corresponding json files from `static_data/countries_world` to `static_data/countries`.

## Generating OSM layers

Pipeline for generating OSM layers looks like this: 

1. downloading OSM planet
2. extracting from OSM planet country region
3. importing country region extract into database
4. mapping OSM features to MapAction layers
5. exporting from database to SHP/GeoJSON files
6. uploading files to CKAN


## Generating population tabular data from HDX

Because of ununiform naming of population tabular data on HDX it was implemented using `static_data/hdx_admin_pop_urls.json` file.
The script filters values using country code and downloads this layers.

__TO ADD OR UPDATE NEW LAYER__

1. add OR update `static_data/hdx_admin_pop_urls.json`