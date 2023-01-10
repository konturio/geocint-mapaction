drop table if exists :ma_table;

create table :ma_table(id bigserial primary key,
    country_code text,
    ma_category text,
    ma_theme text,
    ma_tag text,
    fclass text,
    feature_type text,
    osm_minimum_tags jsonb,
    osm_id bigint,
    osm_type text,
    geom geometry(geometry, 4326));


--
drop type if exists tran_rds_roads_ln;
create type tran_rds_roads_ln as(
    "name" text,
    "oneway" text,
    "max speed" text,
    "bridge" text,
    "tunnel" text,
    "surface" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'rds',
    'roads',
    tags ->> 'highway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where
    (tags @> '{"highway":"residential"}' or
    tags @> '{"highway":"service"}' or
    tags @> '{"highway":"track"}' or
    tags @> '{"highway":"living_street"}' or
    tags @> '{"highway":"motorway"}' or
    tags @> '{"highway":"motorway_link"}' or
    tags @> '{"highway":"trunk"}' or
    tags @> '{"highway":"trunk_link"}' or
    tags @> '{"highway":"primary"}' or
    tags @> '{"highway":"primary_link"}' or
    tags @> '{"highway":"secondary"}' or
    tags @> '{"highway":"secondary_link"}')
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_rds_mainroads_ln;
create type tran_rds_mainroads_ln as(
    "name" text,
    "name:en" text,
    "int_name" text,
    "surface" text,
    "ref" text,
    "maxspeed" text,
    "lanes" text,
    "oneway" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'rds',
    'mainroads',
    replace(tags ->> 'highway', '_link', '' ),
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    (tags @> '{"highway":"motorway"}' or
    tags @> '{"highway":"motorway_link"}' or
    tags @> '{"highway":"trunk"}' or
    tags @> '{"highway":"trunk_link"}' or
    tags @> '{"highway":"primary"}' or
    tags @> '{"highway":"primary_link"}' or
    tags @> '{"highway":"secondary"}' or
    tags @> '{"highway":"secondary_link"}')
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_rrd_railway_ln;
create type tran_rrd_railway_ln as(
    "name" text,
    "name:en" text,
    "electrified" text,
    "usage" text,
    "gauge" text,
    "service" text,
    "voltage" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'rrd',
    'railway',
    tags ->> 'railway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    (tags @> '{"railway":"rail"}' or
    tags @> '{"railway":"narrow_gauge"}' or
    tags @> '{"railway":"subway"}')
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_rrd_subwaytram_ln;
create type tran_rrd_subwaytram_ln as(
    "name" text,
    "name:en" text,
    "electrified" text,
    "service" text,
    "gauge" text,
    "oneway" text,
    "voltage" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'rrd',
    'subwaytram',
    tags ->> 'railway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where
    (tags @> '{"railway":"subway"}' or
    tags @> '{"railway":"tram"}')
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_rst_railway_station_pt;
create type tran_rst_railway_station_pt as(
    "name" text,
    "name:en" text,
    "int_name" text,
    "train" text,
    "station" text,
    "subway" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'rst',
    'railway_station',
    tags ->> 'railway',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where
    tags @> '{"public_transport":"station"}' or
    tags @> '{"railway":"station"}' or
    tags @> '{"railway":"halt"}';

-- 
drop type if exists phys_dam_dam_pt;
create type phys_dam_dam_pt as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'phys',
    'dam',
    'dam',
    tags ->> 'waterway',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"waterway":"dam"}';

-- 
drop type if exists educ_edu_school_pt;
create type educ_edu_school_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'educ',
    'edu',
    'school',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"school"}';

-- 
drop type if exists educ_uni_universities_pt;
create type educ_uni_universities_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'educ',
    'uni',
    'universities',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"amenity":"college"}' or 
    tags @> '{"amenity":"university"}';

-- 
drop type if exists tran_fte_ferryterminal_pt;
create type tran_fte_ferryterminal_pt as(
    "name" text,
    "name:en" text,
    "ferry" text,
    "cargo" text,
    "public_transport" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'fte',
    'ferryterminal',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"ferry_terminal"}';

-- 
drop type if exists tran_fer_ferryroute_ln;
create type tran_fer_ferryroute_ln as(
    "name" text,
    "name:en" text,
    "ferry" text,
    "port:type" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'fer',
    'ferryroute',
    tags ->> 'route',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"route":"ferry"}'
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_por_port_pt;
create type tran_por_port_pt as(
    "name" text,
    "name:en" text,
    "industrial" text,
    "port:type" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'por',
    'port',
    COALESCE(tags ->> 'landuse', tags ->> 'industrial'),
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"landuse":"port"}' or
    tags @> '{"landuse":"harbour"}' or
    tags @> '{"industrial":"port"}';

-- 
drop type if exists cash_bnk_bank_pt;
create type cash_bnk_bank_pt as(
    "name" text,
    "name:en" text,
    "atm" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'cash',
    'bnk',
    'bank',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"bank"}';

-- 
drop type if exists cash_atm_atm_pt;
create type cash_atm_atm_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text,
    "brand" text,
    "atm" text,
    "operator" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'cash',
    'atm',
    'atm',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"atm":"yes"}' or
    tags @> '{"amenity":"atm"}';

-- 
drop type if exists heal_hea_healthcentres_pt;
create type heal_hea_healthcentres_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text,
    "operator" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'heal',
    'hea',
    'healthcentres',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"amenity":"clinic"}' or
    tags @> '{"amenity":"doctors"}' or
    tags @> '{"amenity":"health_post"}' or
    tags @> '{"amenity":"hospital"}' or
    tags @> '{"amenity":"pharmacy"}';

-- 
drop type if exists heal_hos_hospital_pt;
create type heal_hos_hospital_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'heal',
    'hos',
    'hospital',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"hospital"}';

-- 
drop type if exists cash_mkt_marketplace_pt;
create type cash_mkt_marketplace_pt as(
    "name" text,
    "name:en" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'cash',
    'mkt',
    'marketplace',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"marketplace"}';

-- 
insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'cccm',
    'ref',
    'refugeesite',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"refugee_site"}';

-- 
drop type if exists tran_brg_bridge_pt;
create type tran_brg_bridge_pt as(
    "name" text,
    "name:en" text,
    "bridge" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'brg',
    'bridge',
    tags ->> 'man_made',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"man_made":"bridge"}';

-- 
drop type if exists util_ppl_pipeline_ln;
create type util_ppl_pipeline_ln as(
    "name" text,
    "name:en" text,
    "substance" text,
    "location" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'util',
    'ppl',
    'pipeline',
    tags ->> 'man_made',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"man_made":"pipeline"}'
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists util_pwl_powerline_ln;
create type util_pwl_powerline_ln as(
    "name" text,
    "name:en" text,
    "voltage" text,
    "cables" text,
    "circuits" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'util',
    'pwl',
    'powerline',
    'power_line',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"power":"line"}'
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists util_pst_powerstation_pt;
create type util_pst_powerstation_pt as(
    "name" text,
    "name:en" text,
    "landuse" text,
    "building" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'util',
    'pst',
    'powerstation',
    tags ->> 'power',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"power":"plant"}';

-- 
drop type if exists util_pst_substation_pt;
create type util_pst_substation_pt as(
    "name" text,
    "name:en" text,
    "substation" text,
    "building" text,
    "voltage" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'util',
    'pst',
    'substation',
    tags ->> 'power',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"power":"substation"}';

-- 
drop type if exists util_mil_militaryinstallation_py;
create type util_mil_militaryinstallation_py as(
    "name" text,
    "name:en" text,
    "landuse" text,
    "building" text,
    "barrier" text,
    "bunker_type" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'util',
    'mil',
    'militaryinstallation',
    tags ->> 'military',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags ? 'military'
    and geometrytype(geog::geometry) ~* 'polygon';

-- 
drop type if exists phys_lak_lake_py;
create type phys_lak_lake_py as(
    "name" text,
    "name:en" text,
    "water" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'phys',
    'lak',
    'lake',
    COALESCE(tags ->> 'natural', tags ->> 'water'),
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    (tags @> '{"water":"lake"}' or
    tags @> '{"water":"reservoir"}')
    and geometrytype(geog) ~* 'polygon';

-- 
drop type if exists phys_riv_river_py;
create type phys_riv_river_py as(
    "name" text,
    "name:en" text,
    "int_name" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'phys',
    'riv',
    'river',
    tags ->> 'water',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"water":"river"}'
    and geometrytype(geog) ~* 'polygon';

-- 
drop type if exists phys_riv_river_ln;
create type phys_riv_river_ln as(
    "name" text,
    "name:en" text,
    "int_name" text,
    "tunnel" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'phys',
    'riv',
    'river',
    tags ->> 'waterway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"waterway":"river"}'
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists tran_can_canal_ln;
create type tran_can_canal_ln as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'tran',
    'can',
    'canal',
    tags ->> 'waterway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"waterway":"canal"}'
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists pois_rel_placeofworship_pt;
create type pois_rel_placeofworship_pt as(
    "name" text,
    "name:en" text,
    "religionn" text,
    "building" text,
    "denomination" text,
    "tourism" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'pois',
    'rel',
    'placeofworship',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"place_of_worship"}';

-- 
drop type if exists pois_bor_bordercrossing_pt;
create type pois_bor_bordercrossing_pt as(
    "name" text,
    "name:en" text,
    "int_name" text,
    "foot" text,
    "bicycle" text,
    "motor_vehicle" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'pois',
    'bor',
    'bordercrossing',
    tags ->> 'barrier',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"barrier":"border_control"}';

-- 
drop type if exists stle_stl_settlements_pt;
create type stle_stl_settlements_pt as(
    "name" text,
    "name:en" text,
    "name:prefix" text,
    "int_name" text,
    "population" text,
    "admin_level" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'stle',
    'stl',
    'settlements',
    CASE WHEN tags @> '{"capital":"yes"}' THEN 'national_capital'
    ELSE tags ->> 'place' END,
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"place":"city"}' or
    tags @> '{"place":"borough"}' or
    tags @> '{"place":"town"}' or
    tags @> '{"place":"village"}' or
    tags @> '{"place":"hamlet"}';

-- 
drop type if exists stle_stl_townscities_pt;
create type stle_stl_townscities_pt as(
    "name" text,
    "name:en" text,
    "int_name" text,
    "population" text,
    "admin_level" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'stle',
    'stl',
    'townscities',
    CASE WHEN tags @> '{"capital":"yes"}' THEN 'national_capital'
    ELSE tags ->> 'place' END,
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"place":"city"}' or
    tags @> '{"place":"town"}';

-- 
drop type if exists wash_toi_toilets_pt;
create type wash_toi_toilets_pt as(
    "name" text,
    "name:en" text,
    "fee" text,
    "access" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'wash',
    'toi',
    'toilets',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"amenity":"toilets"}';

-- 
drop type if exists wash_wts_water_source_pt;
create type wash_wts_water_source_pt as(
    "name" text,
    "name:en" text,
    "man_made" text,
    "drinking_water" text,
    "access" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'wash',
    'wts',
    'water_source',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"amenity":"drinking_water"}' or
    tags @> '{"amenity":"water_point"}';

-- 
drop type if exists admn_ad0_adminboundary0_py;
create type admn_ad0_adminboundary0_py as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'admn',
    'ad0',
    'adminboundary0',
    tags ->> 'admin_level',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"boundary":"administrative"}'
    and tags @> '{"admin_level":"2"}'
    and geometrytype(geog::geometry) ~* 'polygon'
    and tags ->> 'admin_level' ~ '^\d+$';

--
drop type if exists admn_ad1_adminboundary1_py;
create type admn_ad1_adminboundary1_py as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'admn',
    'ad1',
    'adminboundary1',
    tags ->> 'admin_level',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"boundary":"administrative"}'
    and geometrytype(geog::geometry) ~* 'polygon'
    and tags ->> 'admin_level' ~ '^\d+$'
    and tags @> format('{"admin_level":%1$I}', coalesce((select distinct (tags ->> 'admin_level')::int
        from :osm_table
        where  tags @> '{"boundary":"administrative"}'
            and tags ? 'admin_level'
            and geometrytype(geog::geometry) ~* 'polygon'
            and tags ->> 'admin_level' ~ '^\d+$'
        order by 1
        offset 1
        limit 1
    ), 4))::jsonb;

--
drop type if exists admn_ad2_adminboundary2_py;
create type admn_ad2_adminboundary2_py as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'admn',
    'ad2',
    'adminboundary2',
    tags ->> 'admin_level',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"boundary":"administrative"}'
    and geometrytype(geog::geometry) ~* 'polygon'
    and tags ->> 'admin_level' ~ '^\d+$'
    and tags @> format('{"admin_level":%1$I}', coalesce((select distinct (tags ->> 'admin_level')::int
        from :osm_table
        where  tags @> '{"boundary":"administrative"}'
            and tags ? 'admin_level'
            and geometrytype(geog::geometry) ~* 'polygon'
            and tags ->> 'admin_level' ~ '^\d+$'
        order by 1
        offset 2
        limit 1
    ), 6))::jsonb;

--
drop type if exists admn_ad3_adminboundary3_py;
create type admn_ad3_adminboundary3_py as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'admn',
    'ad3',
    'adminboundary3',
    tags ->> 'admin_level',
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags @> '{"boundary":"administrative"}'
    and geometrytype(geog::geometry) ~* 'polygon'
    and tags ->> 'admin_level' ~ '^\d+$'
    and tags ->> 'admin_level' in (select distinct tags ->> 'admin_level'
        from :osm_table
        where  tags @> '{"boundary":"administrative"}'
            and tags ? 'admin_level'
            and geometrytype(geog::geometry) ~* 'polygon'
            and tags ->> 'admin_level' ~ '^\d+$'
        order by 1
        offset 3
    );

-- 
drop type if exists shel_eaa_emergency_pt;
create type shel_eaa_emergency_pt as(
    "name" text,
    "name:en" text,
    "evacuation_center" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'shel',
    'eaa',
    'emergency',
    tags ->> 'emergency ',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where 
    tags @> '{"emergency ":"assembly_point"}';

--
drop type if exists elev_cst_coastline_ln;
create type elev_cst_coastline_ln as(
    "name" text,
    "source" text,
    "place" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'elev',
    'cst',
    'coastline',
    tags ->> 'natural',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where
    tags @> '{"natural":"coastline"}'
    and geometrytype(geog) ~* 'linestring';

--
drop type if exists bldg_bdg_building_py;
create type bldg_bdg_building_py as(
    "name" text,
    "name:en" text,
    "type" text,
    "amenity" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'bldg',
    'bdg',
    'building',
    replace(coalesce(tags ->> 'type', tags ->> 'name', tags ->> 'amenity', tags ->> 'building'), 'yes', 'building'),
    'py',
    geog::geometry as geom,
    tags,
    osm_id,
    osm_type
from :osm_table
where tags ? 'building'
    and geometrytype(geog::geometry) ~* 'polygon';

--
UPDATE :ma_table
SET country_code = lower((select tags ->> 'ISO3166-1:alpha3' as iso_code
    FROM :osm_table
    where tags ->> 'ISO3166-1:alpha3' is not null
    limit 1));
