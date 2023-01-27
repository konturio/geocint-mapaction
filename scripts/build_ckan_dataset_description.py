import sys
import os
import json
from urllib.parse import urljoin, urlparse
from ma_dictionaries import Geoextent
from ma_dictionaries import FeatureCategory
from ma_dictionaries import FeatureSource

# format CKAN tags. Limited set of chars is allowed
def format_tag(s):
    s = s.replace(" ", "_")
    s = s.replace("/", "_")
    return s.lower()


def build_ckan_dataset_description(strOutputFileName, number_of_objects, strFilter, last_known_edit):
    path, fname = os.path.split(strOutputFileName)
    dataset_name = fname.split(".")[0]  # NOTE: this file name without extention
    codes = dataset_name.split("_", 7)

    S3_DATASET_BASE_URL = os.environ['CKAN_DATA_URL']

    geoextent = codes[0]
    category = codes[1]
    theme = codes[2]
    geometry_type = codes[3]
    scale = codes[4]
    source = codes[5]
    permission = codes[6]
    dataset_hum_name = codes[7]

    short_geoextent = Geoextent[geoextent]
    dataset_title = dataset_hum_name.upper() + " -- " + short_geoextent
    dataset_description = "This dataset contains " + dataset_hum_name.upper() + ", extracted from " + FeatureSource[source] + " data for " + short_geoextent + ". "

    if str(number_of_objects) != "Unknown":
        dataset_description = dataset_description + " Number of objects is " + str(number_of_objects) + ". "
    if strFilter != "":
        dataset_description = dataset_description + " Original filter is " + strFilter + "."

    if last_known_edit != "Unknown":
        dataset_description = dataset_description + " Last known edit timestamp: " + last_known_edit

    # NOTE: it's not a json escaping, but  a particularly perverted bug of curl, it does not undertand equal sign
    dataset_description = dataset_description.replace("=", "%3D")

    ckan_dataset_description = {}

    ckan_dataset_description["name"] = dataset_name
    ckan_dataset_description["title"] = dataset_title
    ckan_dataset_description["notes"] = dataset_description
    ckan_dataset_description["owner_org"] = "kontur"
    if source == "osm":
        ckan_dataset_description["url"] = "http://Openstreetmap.org"
        ckan_dataset_description["license_id"] = "odc-odbl"
    elif source == "worldports":
        ckan_dataset_description["url"] = "https://msi.nga.mil/Publications/WPI"
    elif source == "naturalearth":
        ckan_dataset_description["url"] = "https://www.naturalearthdata.com"
        ckan_dataset_description["license_id"] = "other-pd"
    elif source == "gppd":
        ckan_dataset_description["url"] = "https://datasets.wri.org/dataset/globalpowerplantdatabase"
        ckan_dataset_description["license_id"] = "cc-by"
    elif source == "wfp":
        ckan_dataset_description["url"] = "https://geonode.wfp.org/layers"
    elif source == "ourairports":
        ckan_dataset_description["url"] = "https://ourairports.com/data"
    elif source == "healthsites":
        ckan_dataset_description["url"] = "https://www.healthsites.io/"
    elif source == "worldpop":
        ckan_dataset_description["url"] = "https://hub.worldpop.org/"
        ckan_dataset_description["license_id"] = "cc-by"

    ckan_dataset_description["tags"] = [
        {
            "vocabulary_id": None,
            "display_name": FeatureCategory[category],
            "name": format_tag(FeatureCategory[category]),
        },
        {"vocabulary_id": None, "display_name": source, "name": format_tag(source)},
    ]

    ckan_dataset_description["groups"] = [{"name": geoextent}]

    ckan_dataset_description["extras"] = [
        {"key": "last_known_edit", "value": last_known_edit},
        {"key": "geoextent", "value": geoextent},
        {"key": "category", "value": category},
        {"key": "theme", "value": theme},
        {"key": "geometry_type", "value": geometry_type},
        {"key": "scale", "value": scale},
        {"key": "source", "value": source},
        {"key": "permission", "value": permission},
    ]

    if geometry_type in ["pt", "py", "ln"]:
        ckan_dataset_description["resources"] = [
            {
                "name": dataset_title + " in GeoJson format",
                "url": S3_DATASET_BASE_URL + dataset_name + ".geojson.zip",
                "format": "GeoJson",
            },
            {
                "name": dataset_title + " as ESRI shape",
                "url": S3_DATASET_BASE_URL + dataset_name + ".shp.zip",
                "format": "ESRI shape",
            },
        ]
    elif geometry_type == "ras":
        ckan_dataset_description["resources"] = [
            {
                "name": dataset_title + " in TIFF format",
                "url": S3_DATASET_BASE_URL + dataset_name + ".tif.zip",
                "format": "TIFF",
            }
        ]

    elif geometry_type == "tab":
        ckan_dataset_description["resources"] = [
            {
                "name": dataset_title + " in CSV format",
                "url": S3_DATASET_BASE_URL + dataset_name + ".csv.zip",
                "format": "CSV",
            }
        ]

    return ckan_dataset_description


def main():
    strInputFileName = sys.argv[1]
    path, fname = os.path.split(strInputFileName)

    if len(fname.split("_")) == 2:
        command = "cmf"
    else:
        command = "dataset"

    if command == "dataset":
        print(json.dumps(build_ckan_dataset_description(strInputFileName, "Unknown", "", "Unknown")))
    elif command == "cmf":
        raise Exception("TODO: Crash Move Folder printer")
    else:
        raise Exception('Unknown command "' + command + '". Allowed commands are "dataset" and "cmf"')


if __name__ == "__main__":
    main()
