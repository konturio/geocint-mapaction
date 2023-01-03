# geocint-mapaction

## Setting up AWS credentials

Since pipeline uploads produced datasets in S3 bucket you need to make sure:
1. `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` are specified in environment variables. Please check this [manual](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) for more informarmation or use `aws configure`.

## CKAN configuration

1. `CKAN_BASE_URL` in `config.inc.sh` should be set to url of your CKAN installation, for example `https://test.kontur.io/ckan`.
2. `CKAN_API_KEY` in `config.in.sh` should be set to API key manually generated from CKAN UI (User Profile > Manage > API tokens). You can find more information in CKAN [documentation](https://docs.ckan.org/en/2.9/api/#authentication-and-api-tokens).
3. In `config.inc.sh` variable `CKAN_DATA_S3_URL` should be specified to path in S3 where you expect datasets to be uploaded, for example `s3://geodata-eu-central-1-kontur-public/mapaction_dataset/` and variable `CKAN_DATA_URL` should point at the same path in S3 as `CKAN_DATA_S3_URL` but using http protocol, for example `https://geodata-eu-central-1-kontur-public.s3.amazonaws.com/mapaction_dataset/`.