import sys
import os
import json
from urllib.parse import urljoin
from ma_dictionaries import Geoextent
from ma_dictionaries import FeatureCategory
from ma_dictionaries import FeatureSource

def ckan_cmf_description(filename):
    # url to downloading zip dataset from enviroment
    CNT_DATA_URL = (os.environ['CKAN_DATA_URL']).replace('s3', 'http')
    path, fname = os.path.split(filename)
    dataset_name = fname.split('.')[0] # file name without extention
    codes = dataset_name.split("_", 7)

    geoextent = codes[0]

    short_geoextent = Geoextent[geoextent]

    print('{')
    print('    "name": "'+dataset_name+'",')
    print('    "title": "'+short_geoextent+' Crash Move Folder",')
    print('    "notes": "This dataset contains '+ short_geoextent+' Crash Move Folder. Various layers are combined. This dataset is intended to be used for map making",')
    print('    "url": "mapaction.org",')
    print('    "owner_org": "kontur",')
    print('    "tags": [')
    print('             {"vocabulary_id": null,  "display_name": "cmf",  "name": "cmf"}')
    print('            ],')
    print('    "groups": [{"name": "'+geoextent+'"}')
    print('              ],')
    print('    "extras": [')
    print('             {"key": "last_known_edit", "value": "unknown"},')
    print('             {"key": "geoextent",            "value": "'+ geoextent +'"},')
    print('             {"key": "source",               "value": "osm"},')
    print('             {"key": "permission",           "value": "pp"} ],')
    print('    "resources": [')
    print('        {"name":"'+short_geoextent+' Crash Move Folder in GeoJson format",')
    print(f'         "url": "{urljoin(CNT_DATA_URL, geoextent)}.geojson.zip",')
    print('         "format": "GeoJson"')
    print('        },')
    print('        {"name":"'+short_geoextent+' Crash Move Folder as ESRI shape",')
    print(f'         "url":"{urljoin(CNT_DATA_URL, geoextent)}.shp.zip",')
    print('         "format": "ESRI shape"')
    print('        }]')
    print('}')

if __name__ == "__main__":
    ckan_cmf_description(sys.argv[1])
