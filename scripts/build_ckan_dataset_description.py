import sys
import os
import json
import datetime
from urllib.parse import urljoin, urlparse
from ma_dictionaries import Geoextent
from ma_dictionaries import FeatureCategory
from ma_dictionaries import FeatureSource

DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

SourceFiles ={
    'gppd': "data/in/mapaction/global_power_plant_database.zip",
    'healthsites': "data/in/mapaction/healthsites-world.zip",
    'naturalearth': "data/in/mapaction/ne_10m_roads.zip",
    'osm': "data/planet-latest-updated.osm.pbf",
    'ourairports': "data/in/mapaction/ourairports/airports.csv",
    'srtm': "data/in/srtm30m/_list_files.txt",
    'gmted2010': "data/in/gmted250m/gmted250m.zip",
    'wfp': "data/in/mapaction/wfp_railroads.zip",
    'worldports': "data/in/mapaction/worldports/worldports.csv",
    'unocha': "data/in/mapaction/ocha_admin_boundaries"
    # 'worldpop': "",
}

# format CKAN tags. Limited set of chars is allowed
def format_tag(s):
    s = s.replace(" ", "_")
    s = s.replace("/", "_")
    return s.lower()

def determine_dataset_dates(source, geoextent, geocint_folder, dataset_filename):

    # dataset creation date is when dataset file was created
    creation_timestamp = datetime.datetime.utcfromtimestamp(os.path.getmtime(dataset_filename))

    # download date -- when the source is downloaded. We will take time stamp of the downloaded file.
    if source == 'worldpop':
        download_timestamp = creation_timestamp #worldpop is downladed directly to the out folder.
    elif source == 'unocha':
        #hdx admin boundaries are downloaded per country.
        source_path=os.path.join(os.path.join(geocint_folder,SourceFiles[source]), geoextent)
        download_timestamp = datetime.datetime.utcfromtimestamp(
            os.path.getmtime(source_path))
    else:
        if source in SourceFiles:
            download_timestamp = datetime.datetime.utcfromtimestamp(
                os.path.getmtime(os.path.join(geocint_folder, SourceFiles[source])))
        else:
            download_timestamp = ""
            sys.stderr.write("WARNING: download date of "+source+" source cannot be obtained. No origin file specified for this source. \n")

    if source == "srtm" or "gmted2010":
        # for some sources reference date is known and will not change
        # space shuttle is no longer in service
        reference_timestamp = "2010-01-01T00:00:00Z"
    else:
        # reference date is when the orgin was lastly modified.
        # now let's obtain it from .last_modified.txt file.
        last_modified_file_name = os.path.join(geocint_folder,
                                               os.path.splitext(dataset_filename)[0] + ".last_modified.txt")

        if not os.path.exists(last_modified_file_name):
            if source == "osm":
                last_modified_file_name = os.path.join(geocint_folder, "data/mid/mapaction/"+ geoextent+'.pbf'+ ".last_modified.txt")
            else:
                last_modified_file_name = ""

        if os.path.exists(last_modified_file_name):
            fo1 = open(last_modified_file_name, 'r', encoding="utf-8")
            reference_timestamp = fo1.read()
            reference_timestamp = reference_timestamp.replace("\n",'')
            fo1.close
        else:
            reference_timestamp = ""
            sys.stderr.write("WARNING: unable to determine reference date for "+dataset_filename+"\n")

    if download_timestamp=="":
        download_timestamp="unknown"
    else:
        download_timestamp =download_timestamp.strftime(DATE_FORMAT)

    if reference_timestamp == "":
        reference_timestamp = "unknown"

    return creation_timestamp.strftime(DATE_FORMAT), download_timestamp, reference_timestamp


def build_ckan_dataset_description(strOutputFileName, number_of_objects, strFilter):
    path, fname = os.path.split(strOutputFileName)
    dataset_name = fname.split(".")[0]  # NOTE: this file name without extention
    codes = dataset_name.split("_", 7)

    S3_DATASET_BASE_URL = os.environ['CKAN_DATA_URL']
    GEOCINT_WORK_DIRECTORY = os.environ['GEOCINT_WORK_DIRECTORY']

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

    # NOTE: it's not a json escaping, but a particularly perverted bug of curl, it does not undertand equal sign
    dataset_description = dataset_description.replace("=", "%3D")

    ckan_dataset_description = {}

    ckan_dataset_description["name"] = dataset_name
    ckan_dataset_description["title"] = dataset_title
    ckan_dataset_description["notes"] = dataset_description
    ckan_dataset_description["owner_org"] = "kontur"

    # determine dataset source and license.  
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
    elif source == "unocha":
        ckan_dataset_description["url"] = "https://data.humdata.org/organization/un-ocha"
        ckan_dataset_description["license_id"] = "cc-by"
    elif source == "worldpop":
        ckan_dataset_description["url"] = "https://hub.worldpop.org/"
        ckan_dataset_description["license_id"] = "cc-by"
    elif source == "srtm":
        ckan_dataset_description["url"] = "https://www.usgs.gov/"
        ckan_dataset_description["license_id"] = "other-pd"
    elif source == "gmted2010":
        ckan_dataset_description["url"] = "https://www.usgs.gov/"
        ckan_dataset_description["license_id"] = "other-pd"

    creation_timestamp, download_timestamp, reference_timestamp = determine_dataset_dates(source, geoextent,os.path.join(GEOCINT_WORK_DIRECTORY,"geocint"), strOutputFileName)

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
        {"key": "geoextent", "value": geoextent},
        {"key": "category", "value": category},
        {"key": "theme", "value": theme},
        {"key": "geometry_type", "value": geometry_type},
        {"key": "scale", "value": scale},
        {"key": "source", "value": source},
        {"key": "permission", "value": permission},
        {"key": "creation_date", "value": creation_timestamp},
        {"key": "download_date", "value": download_timestamp},
        {"key": "reference_date", "value": reference_timestamp},
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
        print(json.dumps(build_ckan_dataset_description(strInputFileName, "Unknown", ""), indent=3))
    elif command == "cmf":
        raise Exception("TODO: Crash Move Folder printer")
    else:
        raise Exception('Unknown command "' + command + '". Allowed commands are "dataset" and "cmf"')


if __name__ == "__main__":
    main()
