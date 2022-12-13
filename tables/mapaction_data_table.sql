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
    geom geometry(geometry, 4326));


--
drop type if exists tran_rds_roads_ln;
create type tran_rds_roads_ln as("name" text,
    "oneway" text,
    "max speed" text,
    "bridge" text,
    "tunnel" text,
    "surface" text);

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'rds',
    'roads',
    tags ->> 'highway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'rds',
    'mainroads',
    replace(tags ->> 'highway', '_link', '' ),
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'rrd',
    'railway',
    tags ->> 'railway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'rrd',
    'subwaytram',
    tags ->> 'railway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
from :osm_table
where
    (tags @> '{"railway":"subway"}' or
    tags @> '{"railway":"tram"}')
    and geometrytype(geog) ~* 'linestring';

-- 
drop type if exists phys_dam_dam_pt;
create type phys_dam_dam_pt as(
    "name" text,
    "name:en" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'phys',
    'dam',
    'dam',
    tags ->> 'waterway',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"waterway":"dam"}';

-- 
drop type if exists educ_edu_school_pt;
create type educ_edu_school_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'educ',
    'edu',
    'school',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"school"}';

-- 
drop type if exists educ_uni_pt;
create type educ_uni_pt as(
    "name" text,
    "name:en" text,
    "addr:city" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'educ',
    'uni',
    '',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'fte',
    'ferryterminal',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'fer',
    'ferryroute',
    tags ->> 'route',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'por',
    'port',
    COALESCE(tags ->> 'landuse', tags ->> 'industrial'),
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'cash',
    'bnk',
    'bank',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'cash',
    'atm',
    'atm',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'heal',
    'hea',
    'healthcentres',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'heal',
    'hos',
    'hospital',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"hospital"}';

-- 
drop type if exists cash_mkt_marketplace_pt;
create type cash_mkt_marketplace_pt as(
    "name" text,
    "name:en" text,
    "opening_hours" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'cash',
    'mkt',
    'marketplace',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"marketplace"}';

-- 
insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'cccm',
    'ref',
    'refugeesite',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"refugee_site"}';

-- 
create type tran_brg_bridge_ln as(
    "name" text,
    "name:en" text,
    "bridge" text,
    "substance" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'brg',
    'bridge',
    COALESCE(tags ->> 'man_made', tags ->> 'bridge'),
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
    "location" text,
    "substance" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'util',
    'ppl',
    'pipeline',
    tags ->> 'man_made',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
=======
insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'util',
    'ppl',
    'pipeline',
    '',
    'ln',
    geog::geometry as geom,
    tags
>>>>>>> a1706a3 (13288-create-dataset-export-per-country-both-json-and-shp)
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'util',
    'pwl',
    'powerline',
    tags ->> 'power',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'util',
    'pst',
    'powerstation',
    tags ->> 'power',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'util',
    'pst',
    'substation',
    tags ->> 'power',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'util',
    'mil',
    'militaryinstallation',
    tags ->> 'military',
    'py',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'phys',
    'lak',
    'lake',
    COALESCE(tags ->> 'natural', tags ->> 'water'),
    'py',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'phys',
    'riv',
    'river',
    tags ->> 'water',
    'py',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'phys',
    'riv',
    'river',
    tags ->> 'waterway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'tran',
    'can',
    'canal',
    tags ->> 'waterway',
    'ln',
    geog::geometry as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'pois',
    'rel',
    'placeofworship',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'pois',
    'bor',
    'bordercrossing',
    tags ->> 'barrier',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"border":"border_control"}';

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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'stle',
    'stl',
    'settlements',
    CASE WHEN tags @> '{"capital":"yes"}' THEN 'national_capital'
    ELSE tags ->> 'place' END,
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'stle',
    'stl',
    'townscities',
    CASE WHEN tags @> '{"capital":"yes"}' THEN 'national_capital'
    ELSE tags ->> 'place' END,
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
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

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'wash',
    'toi',
    'toilets',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"toilet"}';

-- 
<<<<<<< HEAD
drop type if exists wash_wts_water_source_pt;
create type wash_wts_water_source_pt as(
    "name" text,
    "name:en" text,
    "man_made" text,
    "drinking_water" text,
    "access" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'wash',
    'wts',
    'water_source',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"water_source"}';

-- 
drop type if exists wash_wts_water_source_pt;
create type wash_wts_water_source_pt as(
    "name" text,
    "name:en" text,
    "man_made" text,
    "drinking_water" text,
    "access" text
    );

insert into :ma_table(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags, osm_id)
select 'wash',
    'wts',
    'water_source',
    tags ->> 'amenity',
    'pt',
    case when geometrytype(geog::geometry) !~* 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags,
    osm_id
from :osm_table
where tags @> '{"amenity":"water_source"}';

-- 
UPDATE :ma_table
SET country_code = (select tags ->> 'ISO3166-1:alpha3' as iso_code
    FROM :osm_table
    where tags ->> 'ISO3166-1:alpha3' is not null
    limit 1);
