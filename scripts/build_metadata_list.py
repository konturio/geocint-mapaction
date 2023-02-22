#
# this script creates "metadata list", i.e a list of datasets with appropriate attributes,
# which should be included into CMF Active Data archive
#
import json
import sys
import os
import pathlib
import datetime
from ma_dictionaries import FeatureSource
from ma_dictionaries import FeatureCategoryCodes


def get_datasets_filenames_datetime(geoextent, files_folder):
    datasets = []
    modifiedTimes = []
    for (root, dirs, files) in os.walk(files_folder, topdown=True):
        for file in files:
            modifiedTime = datetime.datetime.utcfromtimestamp(os.path.getmtime(root + "/" + file))
            if (file[0:3] == geoextent) or (file[0:3] == 'reg'):
                dataset_name = file.split('.')[0]
                if datasets.count(dataset_name) == 0:
                    datasets.append(dataset_name)
                    # data size
                    modifiedTimes.append(modifiedTime.strftime("%Y-%m-%dT%H:%M:%SZ"))
    # return data name and size
    return datasets, modifiedTimes


def get_extras_value(data,key):
    for item in data['extras']:
        if item['key'] == key:
            return item['value']
    return ""

def create_csv(output_file_name,geoextent, datasets):

    fo = open(output_file_name, 'w', encoding="utf-8")
    fo.write('Dataset Name' + ',')
    fo.write('Folder' + ',')
    fo.write('Title' + ',')
    fo.write('Source' + ',')  # ['source']
    fo.write('Source Url,')
    fo.write('License,')
    fo.write('File Creation Date,')
    fo.write('Download Date,')
    fo.write('Reference Date')
    fo.write('\n')

    GEOCINT_WORK_DIRECTORY = os.environ['GEOCINT_WORK_DIRECTORY']
    ckan_json_folder = os.path.join(GEOCINT_WORK_DIRECTORY,"geocint/data/out/country_extractions")

    for dataset_name in datasets[0]:

        if ((dataset_name[0:3] == geoextent) or (dataset_name[0:3] == 'reg')):
            codes = dataset_name.split("_", 7)
            # for some reason, _ckan.json files inculde dataset extension.
            # we should guess it from geometry type
            Extentions = {"pt": ".geojson", "ln": ".geojson", "py": ".geojson", "ras": ".tif", "tab": ".csv"}

            file_extension = Extentions[codes[3]]

            f = open(os.path.join(ckan_json_folder,dataset_name+file_extension+'_ckan.json'))
            data = json.load(f)
            source = get_extras_value(data, "source")
            folder_name = FeatureCategoryCodes[get_extras_value(data, "category")] + '_' + get_extras_value(data, "category")

            # dataset creation date is when dataset file was created
            creation_timestamp = get_extras_value(data, "creation_date").replace("T"," ").replace("Z","")
            download_timestamp = get_extras_value(data, "download_date").replace("T"," ").replace("Z","")
            reference_timestamp = get_extras_value(data, "reference_date").replace("T"," ").replace("Z","")

            fo.write(dataset_name + ',')

            fo.write(folder_name + ',')  # ['source']
            fo.write(data['title'] + ',')
            # fo.write('"'+data['notes']+ '", ')

            fo.write(FeatureSource[source] + ',')  # ['source']

            fo.write(data.get('url','') + ',')
            fo.write(data.get('license_id', '') + ',')

            fo.write(creation_timestamp +',')
            if download_timestamp != "unknown":
                fo.write(download_timestamp+',')
            else:
                fo.write(",")

            if reference_timestamp != "unknown":
                fo.write(reference_timestamp+',')

            fo.write('\n')
            f.close()

    fo.close()


def main():
    # input from bash find command
    # example: data/out/country_extractions/tza
    country_data_folder = sys.argv[1]

    # optional output file name
    #specify it if you need to test this script separately
    if len(sys.argv)>2:
        output_file_name = sys.argv[2]
    else:
        output_file_name = os.path.join(country_data_folder,"dataset_metadata.csv")

    country_code = os.path.basename(country_data_folder)
    files = get_datasets_filenames_datetime(country_code, country_data_folder)
    create_csv(output_file_name,country_code, files)


if __name__ == '__main__':
    main()