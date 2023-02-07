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
    (tags @> '{"atm":"yes"}' or tags @> '{"amenity":"atm"}') and
    not tags @> '{"amenity":"bank"}';

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
    CASE WHEN tags @> '{"is_capital":"country"}' or tags @> '{"admin_level":"2"}' or (tags @> '{"capital":"yes"}' and not tags ? 'admin_level')
    THEN 'national_capital'
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
    'stle',
    'townscities',
    CASE WHEN tags @> '{"is_capital":"country"}' or tags @> '{"admin_level":"2"}' or (tags @> '{"capital":"yes"}' and not tags ? 'admin_level')
    THEN 'national_capital'
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
    coalesce(ST_Difference(geog::geometry, clipgeom), geog::geometry) as geom,
    tags,
    osm_id,
    osm_type
from :osm_table as a, 
    lateral (select st_union(b.geom) as clipgeom
        from water_polygons as b
        where ST_Intersects(geog::geometry, b.geom)) as clip
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
drop type if exists pois_poi;
create type pois_poi as(
    "name" text,
    "name:en" text,
    "type" text,
    "amenity" text,
    "office" text,
    "landuse" text,
    "leisure" text,
    "sport" text,
    "tourism" text,
    "shop" text,
    "vending" text,
    "historic" text,
    "emergency" text,
    "man_made" text
    );

with q as (select * from :osm_table where geometrytype(geog::geometry) !~* 'linestring')
, public as (
    select 'police' as fclass, * from q where tags @> '{"amenity":"police"}'
    union all
    select 'fire_station', * from q where tags @> '{"amenity":"fire_station"}'
    union all
    select 'post_box', * from q where tags @> '{"amenity":"post_box"}'
    union all
    select 'post_office', * from q where tags @> '{"amenity":"post_office"}'
    union all
    select 'telephone', * from q where tags @> '{"amenity":"telephone"}'
    union all
    select 'library', * from q where tags @> '{"amenity":"library"}'
    union all
    select 'town_hall', * from q where tags @> '{"amenity":"townhall"}'
    union all
    select 'courthouse', * from q where tags @> '{"amenity":"courthouse"}'
    union all
    select 'prison', * from q where tags @> '{"amenity":"prison"}'
    union all
    select 'embassy', * from q where tags @> '{"amenity":"embassy"}' or tags @> '{"office":"diplomatic"}'
    union all
    select 'community_centre', * from q where tags @> '{"amenity":"community_centre"}'
    union all
    select 'nursing_home', * from q where tags @> '{"amenity":"nursing_home"}'
    union all
    select 'arts_centre', * from q where tags @> '{"amenity":"arts_centre"}'
    union all
    select 'graveyard', * from q where tags @> '{"amenity":"grave_yard"}' or tags @> '{"landuse":"cemetery"}'
    union all
    select 'market_place', * from q where tags @> '{"amenity":"marketplace"}'
    union all
    select 'recycling', * from q where tags @> '{"amenity":"recycling"}' and not (tags @> '{"recycling:glass":"yes"}' or tags @> '{"recycling:glass_bottles":"yes"}' or tags @> '{"recycling:paper":"yes"}' or tags @> '{"recycling:clothes":"yes"}' or tags @> '{"recycling:scrap_metal":"yes"}')
    union all
    select 'recycling_glass', * from q where tags @> '{"recycling:glass":"yes"}' or tags @> '{"recycling:glass_bottles":"yes"}'
    union all
    select 'recycling_paper', * from q where tags @> '{"recycling:paper":"yes"}'
    union all
    select 'recycling_clothes', * from q where tags @> '{"recycling:clothes":"yes"}'
    union all
    select 'recycling_metal', * from q where tags @> '{"recycling:scrap_metal":"yes"}'
)
, education as (
    select 'university' as fclass, * from q where tags @> '{"amenity":"university"}'
    union all
    select 'school', * from q where tags @> '{"amenity":"school"}'
    union all
    select 'kindergarten', * from q where tags @> '{"amenity":"kindergarten"}'
    union all
    select 'college', * from q where tags @> '{"amenity":"college"}'
    union all
    select 'public_building', * from q where tags @> '{"amenity":"public_building"}'
)
, health as (
    select 'pharmacy' as fclass, * from q where tags @> '{"amenity":"pharmacy"}'
    union all
    select 'hospital', * from q where tags @> '{"amenity":"hospital"}'
    union all
    select 'clinic', * from q where tags @> '{"amenity":"clinic"}'
    union all
    select 'doctors', * from q where tags @> '{"amenity":"doctors"}'
    union all
    select 'dentist', * from q where tags @> '{"amenity":"dentist"}'
    union all
    select 'veterinary', * from q where tags @> '{"amenity":"veterinary"}'
)
, leisure as (
    select 'theatre' as fclass, * from q where tags @> '{"amenity":"theatre"}'
    union all
    select 'nightclub', * from q where tags @> '{"amenity":"nightclub"}'
    union all
    select 'cinema', * from q where tags @> '{"amenity":"cinema"}'
    union all
    select 'park', * from q where tags @> '{"leisure":"park"}'
    union all
    select 'playground', * from q where tags @> '{"leisure":"playground"}'
    union all
    select 'dog_park', * from q where tags @> '{"leisure":"dog_park"}'
)
, sports as (
    select 'sports_centre' as fclass, * from q where tags @> '{"leisure":"sports_centre"}'
    union all
    select 'pitch', * from q where tags @> '{"leisure":"pitch"}'
    union all
    select 'swimming_pool', * from q where tags @> '{"amenity":"swimming_pool"}' or tags @> '{"leisure":"swimming_pool"}' or tags @> '{"sport":"swimming"}' or tags @> '{"leisure":"water_park"}'
    union all
    select 'tennis_court', * from q where tags @> '{"sport":"tennis"}'
    union all
    select 'golf_course', * from q where tags @> '{"leisure":"golf_course"}'
    union all
    select 'stadium', * from q where tags @> '{"leisure":"stadium"}'
    union all
    select 'ice_rink', * from q where tags @> '{"leisure":"ice_rink"}'
)
, catering as (
    select 'restaurant' as fclass, * from q where tags @> '{"amenity":"restaurant"}'
    union all
    select 'fast_food', * from q where tags @> '{"amenity":"fast_food"}'
    union all
    select 'cafe', * from q where tags @> '{"amenity":"cafe"}'
    union all
    select 'pub', * from q where tags @> '{"amenity":"pub"}'
    union all
    select 'bar', * from q where tags @> '{"amenity":"bar"}'
    union all
    select 'food_court', * from q where tags @> '{"amenity":"food_court"}'
    union all
    select 'biergarten', * from q where tags @> '{"amenity":"biergarten"}'
)
, accommodation as (
    select 'hotel' as fclass, * from q where tags @> '{"tourism":"hotel"}'
    union all
    select 'motel', * from q where tags @> '{"tourism":"motel"}'
    union all
    select 'bed_and_breakfast', * from q where tags @> '{"tourism":"bed_and_breakfast"}'
    union all
    select 'guesthouse', * from q where tags @> '{"tourism":"guest_house"}'
    union all
    select 'hostel', * from q where tags @> '{"tourism":"hostel"}'
    union all
    select 'chalet', * from q where tags @> '{"tourism":"chalet"}'
    union all
    select 'shelter', * from q where tags @> '{"amenity":"shelter"}'
    union all
    select 'camp_site', * from q where tags @> '{"tourism":"camp_site"}'
    union all
    select 'alpine_hut', * from q where tags @> '{"tourism":"alpine_hut"}'
    union all
    select 'caravan_site', * from q where tags @> '{"tourism":"caravan_site"}'
)
, shopping as (
    select 'supermarket' as fclass, * from q where tags @> '{"shop":"supermarket"}'
    union all
    select 'bakery', * from q where tags @> '{"shop":"bakery"}'
    union all
    select 'kiosk', * from q where tags @> '{"shop":"kiosk"}'
    union all
    select 'mall', * from q where tags @> '{"shop":"mall"}'
    union all
    select 'department_store', * from q where tags @> '{"shop":"department_store"}'
    union all
    select 'general', * from q where tags @> '{"shop":"general"}'
    union all
    select 'convenience', * from q where tags @> '{"shop":"convenience"}'
    union all
    select 'clothes', * from q where tags @> '{"shop":"clothes"}'
    union all
    select 'florist', * from q where tags @> '{"shop":"florist"}'
    union all
    select 'chemist', * from q where tags @> '{"shop":"chemist"}'
    union all
    select 'bookshop', * from q where tags @> '{"shop":"books"}'
    union all
    select 'butcher', * from q where tags @> '{"shop":"butcher"}'
    union all
    select 'shoe_shop', * from q where tags @> '{"shop":"shoes"}'
    union all
    select 'beverages', * from q where tags @> '{"shop":"alcohol"}' or tags @> '{"shop":"beverages"}'
    union all
    select 'optician', * from q where tags @> '{"shop":"optician"}'
    union all
    select 'jeweller', * from q where tags @> '{"shop":"jewelry"}'
    union all
    select 'gift_shop', * from q where tags @> '{"shop":"gift"}'
    union all
    select 'sports_shop', * from q where tags @> '{"shop":"sports"}'
    union all
    select 'stationery', * from q where tags @> '{"shop":"stationery"}'
    union all
    select 'outdoor_shop', * from q where tags @> '{"shop":"outdoor"}'
    union all
    select 'mobile_phone_shop', * from q where tags @> '{"shop":"mobile_phone"}'
    union all
    select 'toy_shop', * from q where tags @> '{"shop":"toys"}'
    union all
    select 'newsagent', * from q where tags @> '{"shop":"newsagent"}'
    union all
    select 'greengrocer', * from q where tags @> '{"shop":"greengrocer"}'
    union all
    select 'beauty_shop', * from q where tags @> '{"shop":"beauty"}'
    union all
    select 'video_shop', * from q where tags @> '{"shop":"video"}'
    union all
    select 'car_dealership', * from q where tags @> '{"shop":"car"}'
    union all
    select 'bicycle_shop', * from q where tags @> '{"shop":"bicycle"}'
    union all
    select 'doityourself', * from q where tags @> '{"shop":"doityourself"}' and tags @> '{"shop":"hardware"}'
    union all
    select 'furniture_shop', * from q where tags @> '{"shop":"furniture"}'
    union all
    select 'computer_shop', * from q where tags @> '{"shop":"computer"}'
    union all
    select 'garden_centre', * from q where tags @> '{"shop":"garden_centre"}'
    union all
    select 'hairdresser', * from q where tags @> '{"shop":"hairdresser"}'
    union all
    select 'car_repair', * from q where tags @> '{"shop":"car_repair"}'
    union all
    select 'car_rental', * from q where tags @> '{"amenity":"car_rental"}'
    union all
    select 'car_wash', * from q where tags @> '{"amenity":"car_wash"}'
    union all
    select 'car_sharing', * from q where tags @> '{"amenity":"car_sharing"}'
    union all
    select 'bicycle_rental', * from q where tags @> '{"amenity":"bicycle_rental"}'
    union all
    select 'travel_agent', * from q where tags @> '{"shop":"travel_agency"}'
    union all
    select 'laundry', * from q where tags @> '{"shop":"laundry"}' or tags @> '{"shop":"dry_cleaning"}'
    union all
    select 'vending_machine', * from q where tags @> '{"amenity":"vending_machine"}' and not (tags @> '{"vending":"cigarettes"}' or tags @> '{"vending":"parking_tickets"}')
    union all
    select 'vending_cigarette', * from q where tags @> '{"vending":"cigarettes"}'
    union all
    select 'vending_parking', * from q where tags @> '{"vending":"parking_tickets"}'
)
, money as (
    select 'bank' as fclass, * from q where tags @> '{"amenity":"bank"}'
    union all
    select 'atm', * from q where tags @> '{"amenity":"atm"}'
)
, tourism as (
    select 'tourist_info' as fclass, * from q where tags @> '{"tourism":"information"}' and not (tags @> '{"information":"map"}' or tags @> '{"information":"board"}' or tags @> '{"information":"guidepost"}')
    union all
    select 'tourist_map', * from q where tags @> '{"information":"map"}'
    union all
    select 'tourist_board', * from q where tags @> '{"information":"board"}'
    union all
    select 'tourist_guidepost', * from q where tags @> '{"information":"guidepost"}'
    union all
    select 'attraction', * from q where tags @> '{"tourism":"attraction"}'
    union all
    select 'museum', * from q where tags @> '{"tourism":"museum"}'
    union all
    select 'monument', * from q where tags @> '{"historic":"monument"}'
    union all
    select 'memorial', * from q where tags @> '{"historic":"memorial"}'
    union all
    select 'art', * from q where tags @> '{"tourism":"artwork"}'
    union all
    select 'castle', * from q where tags @> '{"historic":"castle"}'
    union all
    select 'ruins', * from q where tags @> '{"historic":"ruins"}'
    union all
    select 'archaeological', * from q where tags @> '{"historic":"archaeological_site"}'
    union all
    select 'wayside_cross', * from q where tags @> '{"historic":"wayside_cross"}'
    union all
    select 'wayside_shrine', * from q where tags @> '{"historic":"wayside_shrine"}'
    union all
    select 'battlefield', * from q where tags @> '{"historic":"battlefield"}'
    union all
    select 'fort', * from q where tags @> '{"historic":"fort"}'
    union all
    select 'picnic_site', * from q where tags @> '{"tourism":"picnic_site"}'
    union all
    select 'viewpoint', * from q where tags @> '{"tourism":"viewpoint"}'
    union all
    select 'zoo', * from q where tags @> '{"tourism":"zoo"}'
    union all
    select 'theme_park', * from q where tags @> '{"tourism":"theme_park"}'
)
, miscpoi as (
    select 'toilet' as fclass, * from q where tags @> '{"amenity":"toilets"}'
    union all
    select 'bench', * from q where tags @> '{"amenity":"bench"}'
    union all
    select 'drinking_water', * from q where tags @> '{"amenity":"drinking_water"}'
    union all
    select 'fountain', * from q where tags @> '{"amenity":"fountain"}'
    union all
    select 'hunting_stand', * from q where tags @> '{"amenity":"hunting_stand"}'
    union all
    select 'waste_basket', * from q where tags @> '{"amenity":"waste_basket"}'
    union all
    select 'camera_surveillance', * from q where tags @> '{"man_made":"surveillance"}'
    union all
    select 'emergency_phone', * from q where tags @> '{"amenity":"emergency_phone"}' or tags @> '{"emergency":"phone"}'
    union all
    select 'fire_hydrant', * from q where tags @> '{"amenity":"fire_hydrant"}' or tags @>  '{"emergency":"fire_hydrant"}'
    union all
    select 'emergency_access', * from q where tags @> '{"highway":"emergency_access _point"}'
    union all
    select 'tower', * from q where tags @> '{"man_made":"tower"}' and not (tags @> '{"tower:type":"communication"}' or tags @> '{"man_made":"water_tower"}' or tags @> '{"tower:type":"observation"}' or tags @> '{"man_made":"windmill"}' or tags @> '{"man_made":"lighthouse"}')
    union all
    select 'tower_comms', * from q where tags @> '{"tower:type":"communication"}'
    union all
    select 'water_tower', * from q where tags @> '{"man_made":"water_tower"}'
    union all
    select 'tower_observation', * from q where tags @> '{"tower:type":"observation"}'
    union all
    select 'windmill', * from q where tags @> '{"man_made":"windmill"}'
    union all
    select 'lighthouse', * from q where tags @> '{"man_made":"lighthouse"}'
    union all
    select 'wastewater_plant', * from q where tags @> '{"man_made":"wastewater_plant"}'
    union all
    select 'water_well', * from q where tags @> '{"man_made":"water_well"}'
    union all
    select 'water_mill', * from q where tags @> '{"man_made":"watermill"}'
    union all
    select 'water_works', * from q where tags @> '{"man_made":"water_works"}'
)
, res as (
    select 'public' as ma_tag, * from public
    union all
    select 'education' as ma_tag, * from education
    union all
    select 'health' as ma_tag, * from health
    union all
    select 'leisure' as ma_tag, * from leisure
    union all
    select 'sports' as ma_tag, * from sports
    union all
    select 'catering' as ma_tag, * from catering
    union all
    select 'accommodation' as ma_tag, * from accommodation
    union all
    select 'shopping' as ma_tag, * from shopping
    union all
    select 'money' as ma_tag, * from money
    union all
    select 'tourism' as ma_tag, * from tourism
    union all
    select 'miscpoi' as ma_tag, * from miscpoi
)
insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id, osm_type)
select 'pois',
    'poi',
    'pointofinterest',
    fclass,
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id,
    osm_type
from res;

--
UPDATE :ma_table
SET country_code = lower((select tags ->> 'ISO3166-1:alpha3' as iso_code
    FROM :osm_table
    where tags ->> 'ISO3166-1:alpha3' is not null
    limit 1));
