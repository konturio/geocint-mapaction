## -------------- EXPORT BLOCK ------------------------

# configuration file
file := ~/config.inc.sh
# Add here export for every varible from configuration file that you are going to use in targets
export USER_NAME = $(shell sed -n -e '/^USER_NAME/p' ${file} | cut -d "=" -f 2)
export SLACK_CHANNEL = $(shell sed -n -e '/^SLACK_CHANNEL/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_NAME = $(shell sed -n -e '/^SLACK_BOT_NAME/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_EMOJI = $(shell sed -n -e '/^SLACK_BOT_EMOJI/p' ${file} | cut -d "=" -f 2)
export SLACK_BOT_KEY = $(shell sed -n -e '/^SLACK_BOT_KEY/p' ${file} | cut -d "=" -f 2)
export CKAN_DATA_S3_URL = $(shell sed -n -e '/^CKAN_DATA_S3_URL/p' ${file} | cut -d "=" -f 2)
export CKAN_DATA_URL = $(shell sed -n -e '/^CKAN_DATA_URL/p' ${file} | cut -d "=" -f 2)
export CKAN_BASE_URL = $(shell sed -n -e '/^CKAN_BASE_URL/p' ${file} | cut -d "=" -f 2)
export CKAN_API_KEY = $(shell sed -n -e '/^CKAN_API_KEY/p' ${file} | cut -d "=" -f 2)

# these makefiles stored in geocint-runner and geocint-openstreetmap repositories
# runner_make contains basic set of targets for creation project folder structure
# osm_make contains contain set of targets for osm data processing
include runner_make osm_make

## ------------- CONTROL BLOCK -------------------------

# replace your_final_target placeholder with the names of final target, that you will use to run pipeline
# you can also add here the names of targets that should not be rebuilt automatically, but only when conditions are met or at your request
all: dev ## [FINAL] Meta-target on top of all other targets, or targets on parking.

# by default the clean target is set to serve an update of the OpenStreetMap planet dump during every run
clean: ## [FINAL] Cleans the worktree for next nightly run. Does not clean non-repeating targets.
	if [ -f data/planet-is-broken ]; then rm -rf data/planet-latest.osm.pbf ; fi
	rm -rf data/planet-is-broken
	profile_make_clean data/planet-latest-updated.osm.pbf

data/in/mapaction: | data/in ## Dir for extract from planet pbf dump
	mkdir -p $@

data/out/mapaction: | data/out ## Dir for exported files
	mkdir -p $@

data/out/country_extractions: | data/out
	mkdir -p $@

data/in/mapaction/ne_10m_rivers_lake_centerlines.zip: | data/in/mapaction ## download ne_10m_rivers_lake_centerlines
	curl "https://naciscdn.org/naturalearth/10m/physical/ne_10m_rivers_lake_centerlines.zip" -o $@

data/in/mapaction/ne_10m_rivers_lake_centerlines: | data/in/mapaction ## ne_10m_rivers_lake_centerlines
	mkdir -p $@

data/in/mapaction/ne_10m_rivers_lake_centerlines/ne_10m_rivers_lake_centerlines.shp: data/in/mapaction/ne_10m_rivers_lake_centerlines.zip | data/in/mapaction/ne_10m_rivers_lake_centerlines ## unzip ne_10m_rivers_lake_centerlines
	unzip data/in/mapaction/ne_10m_rivers_lake_centerlines.zip -d data/in/mapaction/ne_10m_rivers_lake_centerlines
	touch $@

data/out/country_extractions/ne_10m_rivers_lake_centerlines: data/in/mapaction/ne_10m_rivers_lake_centerlines/ne_10m_rivers_lake_centerlines.shp | data/out/country_extractions  ## ne_10m_rivers_lake_centerlines per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_shp.sh {} data/in/mapaction/ne_10m_rivers_lake_centerlines/ne_10m_rivers_lake_centerlines.shp data/out/country_extractions/{country_code}/221_phys/{country_code}_phys_riv_ln_s0_naturalearth_pp_rivers'
	touch $@

data/in/mapaction/ne_10m_roads.zip: | data/in/mapaction ## ne_10m_roads
	curl "https://naciscdn.org/naturalearth/10m/cultural/ne_10m_roads.zip" -o $@

data/in/mapaction/ne_10m_roads: | data/in/mapaction ## ne_10m_roads
	mkdir -p $@

data/in/mapaction/ne_10m_roads/ne_10m_roads.shp: data/in/mapaction/ne_10m_roads.zip | data/in/mapaction/ne_10m_roads ## unzip ne_10m_roads
	unzip data/in/mapaction/ne_10m_roads.zip -d data/in/mapaction/ne_10m_roads
	touch $@

data/out/country_extractions/ne_10m_roads: data/in/mapaction/ne_10m_roads/ne_10m_roads.shp | data/out/country_extractions ## ne_10m_roads per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_shp.sh {} data/in/mapaction/ne_10m_roads/ne_10m_roads.shp data/out/country_extractions/{country_code}/232_tran/{country_code}_tran_rds_ln_s0_naturalearth_pp_roads'
	touch $@

data/in/mapaction/ne_10m_populated_places.zip: | data/in/mapaction ## ne_10m_populated_placess
	curl "https://naciscdn.org/naturalearth/10m/cultural/ne_10m_populated_places.zip" -o $@

data/in/mapaction/ne_10m_populated_places: | data/in/mapaction ## ne_10m_populated_placess
	mkdir -p $@

data/in/mapaction/ne_10m_populated_places/ne_10m_populated_places.shp: data/in/mapaction/ne_10m_populated_places.zip | data/in/mapaction/ne_10m_populated_places ## unzip ne_10m_populated_placess
	unzip data/in/mapaction/ne_10m_populated_places.zip -d data/in/mapaction/ne_10m_populated_places/
	touch $@

data/out/country_extractions/ne_10m_populated_places: data/in/mapaction/ne_10m_populated_places/ne_10m_populated_places.shp | data/out/country_extractions ## ne_10m_populated_placess per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_shp.sh {} data/in/mapaction/ne_10m_populated_places/ne_10m_populated_places.shp data/out/country_extractions/{country_code}/229_stle/{country_code}_stle_stl_pt_s0_naturalearth_pp_maincities'
	touch $@

data/in/mapaction/ne_10m_lakes.zip: | data/in/mapaction ## ne_10m_lakes
	curl "https://naciscdn.org/naturalearth/10m/physical/ne_10m_lakes.zip" -o $@

data/in/mapaction/ne_10m_lakes: | data/in/mapaction ## ne_10m_lakes
	mkdir -p $@

data/in/mapaction/ne_10m_lakes/ne_10m_lakes.shp: data/in/mapaction/ne_10m_lakes.zip | data/in/mapaction/ne_10m_lakes ## unzip ne_10m_lakes
	unzip data/in/mapaction/ne_10m_lakes.zip -d data/in/mapaction/ne_10m_lakes/
	touch $@

data/out/country_extractions/ne_10m_lakes: data/in/mapaction/ne_10m_lakes/ne_10m_lakes.shp | data/out/country_extractions ## ne_10m_lakes per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_shp.sh {} data/in/mapaction/ne_10m_lakes/ne_10m_lakes.shp data/out/country_extractions/{country_code}/221_phys/{country_code}_phys_lak_py_s0_naturalearth_pp_waterbodies'
	touch $@

data/in/mapaction/ourairports: | data/in/mapaction ## Our Airports
	mkdir -p $@

data/in/mapaction/ourairports/airports.csv: | data/in/mapaction/ourairports ## download airports.csv
	curl "https://davidmegginson.github.io/ourairports-data/airports.csv" -o "$@"

data/out/country_extractions/ourairports: data/in/mapaction/ourairports/airports.csv | data/out/country_extractions ## ourairports per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_csv.sh {} data/in/mapaction/ourairports/airports.csv data/out/country_extractions/{country_code}/232_tran/{country_code}_tran_air_pt_s0_ourairports_pp_airports'
	touch $@

data/in/mapaction/worldports: | data/in/mapaction ## World Ports
	mkdir -p $@

data/in/mapaction/worldports/worldports.csv: | data/in/mapaction/worldports ## download worldports.csv
	curl "https://msi.nga.mil/api/publications/download?type=view&key=16920959/SFH00000/UpdatedPub150.csv" -o "$@"

data/out/country_extractions/worldports: data/in/mapaction/worldports/worldports.csv | data/out/country_extractions ## worldports per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_csv.sh {} data/in/mapaction/worldports/worldports.csv data/out/country_extractions/{country_code}/232_tran/{country_code}_tran_por_pt_s0_worldports_pp_ports'
	touch $@

data/in/mapaction/wfp_railroads: | data/in/mapaction ## WFP Railroads
	mkdir -p $@

data/in/mapaction/wfp_railroads.zip: | data/in/mapaction ## download wfp_railroads.zip
	curl "https://geonode.wfp.org/geoserver/wfs?format_options=charset%3AUTF-8&typename=geonode%3Awld_trs_railways_wfp&outputFormat=SHAPE-ZIP&version=1.0.0&service=WFS&request=GetFeature" -o "$@"

data/in/mapaction/wfp_railroads/wld_trs_railways_wfp.shp: data/in/mapaction/wfp_railroads.zip | data/in/mapaction/wfp_railroads ## unzip wfp_railroads.zip
	unzip data/in/mapaction/wfp_railroads.zip -d data/in/mapaction/wfp_railroads
	touch $@

data/out/country_extractions/wfp_railroads: data/in/mapaction/wfp_railroads/wld_trs_railways_wfp.shp | data/out/country_extractions ## wfp railroads per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_shp.sh {} data/in/mapaction/wfp_railroads/wld_trs_railways_wfp.shp data/out/country_extractions/{country_code}/232_tran/{country_code}_tran_rrd_ln_s0_wfp_pp_railways'
	touch $@

data/in/mapaction/global_power_plant_database: | data/in/mapaction ## Global Power Plant Database
	mkdir -p $@

data/in/mapaction/global_power_plant_database.zip: | data/in/mapaction ## download global_power_plant_database.zip
	curl "https://wri-dataportal-prod.s3.amazonaws.com/manual/global_power_plant_database_v_1_3.zip" -o "$@"

data/in/mapaction/global_power_plant_database/global_power_plant_database.csv: data/in/mapaction/global_power_plant_database.zip | data/in/mapaction/global_power_plant_database ## unzip global_power_plant_database.zip
	unzip data/in/mapaction/global_power_plant_database.zip -d data/in/mapaction/global_power_plant_database
	touch $@

data/out/country_extractions/global_power_plant_database: data/in/mapaction/global_power_plant_database/global_power_plant_database.csv | data/out/country_extractions ## global_power_plant_database.csv per country extractions
	ls static_data/countries | parallel 'bash scripts/mapaction_extract_country_from_csv.sh {} data/in/mapaction/global_power_plant_database/global_power_plant_database.csv data/out/country_extractions/{country_code}/233_util/{country_code}_util_pst_pt_s0_gppd_pp_powerplants'
	touch $@

data/out/cmf: | data/out ## create directory for CMFs
	mkdir -p $@

data/out/upload_datasets_all: data/out/country_extractions/ne_10m_lakes data/out/country_extractions/ourairports data/out/country_extractions/worldports data/out/country_extractions/wfp_railroads data/out/country_extractions/global_power_plant_database data/out/country_extractions/ne_10m_rivers_lake_centerlines data/out/country_extractions/ne_10m_populated_places data/out/country_extractions/ne_10m_roads data/out/mapaction_export | data/out ## upload datasets in CKAN
	find data/out/country_extractions/ -name "*.shp" | parallel 'bash scripts/mapaction_upload_dataset.sh {}'
	touch $@

data/out/upload_cmf_all: data/out/country_extractions/ne_10m_lakes data/out/country_extractions/ourairports data/out/country_extractions/worldports data/out/country_extractions/wfp_railroads data/out/country_extractions/global_power_plant_database data/out/country_extractions/ne_10m_rivers_lake_centerlines data/out/country_extractions/ne_10m_populated_places data/out/country_extractions/ne_10m_roads data/out/mapaction_export | data/out/cmf ## upload CMFs in CKAN
	find data/out/country_extractions/ -mindepth 1 -maxdepth 1 -type d | parallel 'bash scripts/mapaction_upload_cmf.sh {}'
	touch $@

osmium_extract_config.json: ## generate config for osmium-extract
	python scripts/generate_osmium_extract_config.py > $@

data/mid/mapaction: | data/mid ## create directory data/mid/mapaction
	mkdir -p $@

data/in/mapaction/per_country_pbf: data/planet-latest-updated.osm.pbf osmium_extract_config.json | data/mid/mapaction ## create per-country extracts pbf files from planet.pbf
	osmium extract --config osmium_extract_config.json --overwrite data/planet-latest-updated.osm.pbf
	touch $@

db/table/osm_data_import: data/in/mapaction/per_country_pbf | db/table ## Create and populate osm_[] tables in db
	ls static_data/countries/*.json | parallel 'bash scripts/osm_data_import.sh {}'
	touch $@

db/table/mapaction_data_table: db/table/osm_data_import | db/table ## Create and populate mapaction_[] tables in db
	ls static_data/countries/*.json | parallel 'bash scripts/mapaction_data_table.sh {}'
	touch $@

db/table/mapaction_directories: | db/table ## Load into db structure of directory to use it while export
	psql -1 -c "drop table if exists mapaction_directories;"
	psql -1 -c "create table mapaction_directories(dir_name text);"
	cat static_data/directories/directories.csv | psql -c "copy mapaction_directories from stdin;"
	touch $@

data/out/mapaction_export: db/table/mapaction_data_table db/table/mapaction_directories | data/out/country_extractions ## Export from db to SHP and JSON
	psql -1 -f scripts/mapaction_data_export.sql
	ls static_data/countries/*.json | parallel 'bash scripts/mapaction_export.sh {}'
	touch $@

dev: data/out/upload_datasets_all data/out/upload_cmf_all ## this runs when autos_tart.sh executes
	echo "dev target successfully build" | python scripts/slack_message.py $$SLACK_CHANNEL ${SLACK_BOT_NAME} $$SLACK_BOT_EMOJI
	touch $@

.PHONY: export_country
export_country: db/table/mapaction_directories data/in/mapaction data/mid/mapaction data/out/mapaction | data/out/country_extractions ## run as make export_country COUNTRY=static_data/countries/blr.json
	osmium extract --overwrite --polygon=$(COUNTRY) data/planet-latest-updated.osm.pbf -o data/mid/mapaction/$(shell (basename $(COUNTRY) .json) ).pbf
	bash scripts/osm_data_import.sh $(COUNTRY)
	bash scripts/mapaction_data_table.sh $(COUNTRY)
	bash scripts/mapaction_export.sh $(COUNTRY)
	bash scripts/mapaction_upload_cmf.sh $(shell echo data/out/country_extractions/$(shell (basename $(COUNTRY) .json) ))
