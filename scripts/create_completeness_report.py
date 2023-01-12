import os, time
import sys
import json

def loadCsv(strInputFile, encoding="utf-8", separator="|", skipheaders=False):
    cells = []
    if os.path.exists(strInputFile):
        filehandle = open(strInputFile, 'r', encoding=encoding)
        txt = filehandle.readline().strip()
        while len(txt) != 0:
            if txt[0:1] != "#":
                row = txt.strip().split(separator)
                for i in range(len(row)):
                    row[i] = row[i].strip()
                if len(row) > 1:
                    cells.append(row)
            txt = filehandle.readline()
        # end of while
        filehandle.close()
        if skipheaders:
            cells.pop(0)
    return cells


FLD_GROUP = 0
FLD_DESCR = 1
FLD_SOURCE = 2
FLD_CATEGORY = 3
FLD_THEME = 4
FLD_TYPE = 5


def get_datasets_filenames_datetime(geoextent, files_folder):
    datasets = []
    modifiedTimes = []
    for (root, dirs, files) in os.walk(files_folder, topdown=True):
        for file in files:
            modifiedTime = time.ctime(os.path.getmtime(root + "/" + file))
            if (file[0:3] == geoextent) or (file[0:3] == 'reg'):
                dataset_name = file.split('.')[0]
                if datasets.count(dataset_name) == 0:
                    datasets.append(dataset_name)
                    # data size
                    modifiedTimes.append(modifiedTime)
    # return data name and size
    return datasets, modifiedTimes


def match_datsets(record, files, geoextent_all):
    matched_datasets = []
    timeValues = []
    for f in files[0]:
        dataset_name = f.split('.',)[0]
        codes = dataset_name.split("_", 7)

        geoextent = codes[0]
        category = codes[1]
        theme = codes[2]
        geometry_type = codes[3]
        scale = codes[4]
        source = codes[5]
        permission = codes[6]
        if len(codes) >= 8:
            dataset_hum_name = codes[7]
        else:
            dataset_hum_name = ''

        rec_geoextent = geoextent_all
        if (record[FLD_DESCR].lower().find('surrounding') != -1):
            rec_geoextent = 'reg'
        if geoextent == rec_geoextent \
                and category == record[FLD_CATEGORY] \
                and (record[FLD_THEME] == '*' or theme == record[FLD_THEME]) \
                and (record[FLD_SOURCE] == '*' or record[FLD_SOURCE] == source)\
                and geometry_type == record[FLD_TYPE]:
            #print (dataset_name & dateTime)
            if matched_datasets.count(dataset_name) == 0:
                matched_datasets.append(dataset_name)
                index = files[0].index(dataset_name)
                timeValues.append(files[1][index])

    for f in matched_datasets:
        index = files[0].index(f)
        files[0].remove(f)
        files[1].pop(index)

    # return both file names and datetime
    return matched_datasets, timeValues

completeness = []
def create_json(country_code, dat, files):
    for record in dat:
        matchedData = match_datsets(record, files, country_code)
        fileNames = matchedData[0]
        dates = matchedData[1]
        if len(fileNames) > 0:
            table_row_class = "ok"
        else:
            table_row_class = "failed"

        dataRecord = {"class": table_row_class,
             "dataset": record[1],
             "source": record[2],
             "category": record[3],
             "theme": record[4],
             "type": record[5]
             }

        multiFileNames = []
        multiDates = []
        for idx, file in enumerate(fileNames):
            multiFileNames.append(file)
            multiDates.append(dates[idx])

        dataRecord["acquiredDatasets"] = multiFileNames
        dataRecord["dateTime"] = multiDates
        completeness.append(dataRecord)

    dataRecord = {"class": "ok",
         "dataset": "other useful datasets",
         "source": "*",
         "category": "*",
         "theme": "*",
         "type": "*"
         }

    multiFileNames = []
    multiDates = []
    for idy, file in enumerate(files[0]):
        multiFileNames.append(file)
        multiDates.append(files[1][idy])

    dataRecord["acquiredDatasets"] = multiFileNames
    dataRecord["dateTime"] = multiDates

    completeness.append(dataRecord)

    fo = open("/report/completeness_" + country_code + ".json", 'w', encoding="utf-8")
    fo.write(json.dumps(completeness))
    fo.close()


def main():
    # country tag. "tza" for tanzania
    country_code = sys.argv[1]
    
    # related country data folder
    country_data_folder = f"/data/out/country_extractions/{country_code}"

    files = get_datasets_filenames_datetime(country_code, country_data_folder)

    dat = loadCsv("/static_data/completeness_test.csv", separator=',', skipheaders=True)
    
    create_json(country_code, dat, files)

if __name__ == '__main__':
    main()
