import sys
import os
import json
from urllib.parse import urljoin, urlparse
from ma_dictionaries import Geoextent
from ma_dictionaries import FeatureCategory
from ma_dictionaries import FeatureSource

def ckan_cmf_description(filename):
    # url to downloading zip dataset from enviroment
    CNT_DATA_URL = os.environ['CKAN_DATA_URL']
    path, fname = os.path.split(filename)
    dataset_name = fname.split('.')[0] # file name without extention
    codes = dataset_name.split("_", 7)

    geoextent = codes[0]

    short_geoextent = Geoextent[geoextent]

    print('{')
    print('    "name": "'+dataset_name+'",')
    print('    "title": "'+short_geoextent+' Active Data",')
    print('    "notes": "This dataset contains '+ short_geoextent+' Active Data. Various layers are combined. This dataset is intended to be used for map making",')
    print('    "url": "mapaction.org",')
    print('    "owner_org": "kontur",')
    print('    "tags": [')
    print('             {"vocabulary_id": null,  "display_name": "Active Data",  "name": "active-data"}')
    print('            ],')
    print('    "groups": [{"name": "'+geoextent+'"}')
    print('              ],')
    print('    "extras": [')
    print('             {"key": "last_known_edit", "value": "unknown"},')
    print('             {"key": "geoextent",            "value": "'+ geoextent +'"},')
    print('             {"key": "source",               "value": "Various public sources, including OSM, HDX and others"},')
    print('             {"key": "permission",           "value": "pp"} ],')
    print('    "resources": [')
    print('        {"name":"'+short_geoextent+' Active Data in GeoJson format",')
    print(f'         "url": "{urljoin(CNT_DATA_URL, geoextent)}_active_data_geojson.zip",')
    print('         "format": "GeoJson"')
    print('        },')
    print('        {"name":"'+short_geoextent+' Active Data as ESRI shape",')
    print(f'         "url":"{urljoin(CNT_DATA_URL, geoextent)}_active_data_shp.zip",')
    print('         "format": "ESRI shape"')
    print('        }]')
    print('}')

if __name__ == "__main__":
    ckan_cmf_description(sys.argv[1])
