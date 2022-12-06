DROP TABLE IF EXISTS lgudyma.mapaction;

create table lgudyma.mapaction(id bigserial primary key,
    country_code text,
    ma_category text, 
    ma_theme text, 
    ma_tag text, 
    fclass text, 
    feature_type text, 
    osm_minimum_tags jsonb, 
    geom geometry(geometry, 4326));

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'tran',
    'rds',
    'roads',
    tags ->> 'highway',
    'line',
    geog::geometry as geom,
    tags
from lgudyma.osm_cnt
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
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'tran',
    'rds',
    'mainroads',
    replace(tags ->> 'highway', '_link', '' ),
    'line',
    geog::geometry as geom,
    tags
from lgudyma.osm_cnt
where 
    tags @> '{"highway":"motorway"}' or
    tags @> '{"highway":"motorway_link"}' or
    tags @> '{"highway":"trunk"}' or
    tags @> '{"highway":"trunk_link"}' or
    tags @> '{"highway":"primary"}' or
    tags @> '{"highway":"primary_link"}' or
    tags @> '{"highway":"secondary"}' or
    tags @> '{"highway":"secondary_link"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'tran',
    'rrd',
    'railway',
    tags ->> 'railway',
    'line',
    geog::geometry as geom,
    tags
from lgudyma.osm_cnt
where 
    (tags @> '{"railway":"rail"}' or
    tags @> '{"railway":"narrow_gauge"}' or
    tags @> '{"railway":"subway"}')
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'tran',
    'rrd',
    'subwaytram',
    tags ->> 'railway',
    'line',
    geog::geometry as geom,
    tags
from lgudyma.osm_cnt
where
    (tags @> '{"railway":"subway"}' or
    tags @> '{"railway":"tram"}')
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom, osm_minimum_tags)
select 'phys',
    'dam',
    'dam',
    tags ->> 'waterway',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom,
    tags
from lgudyma.osm_cnt
where tags @> '{"waterway":"dam"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'educ',
    'edu',
    'school',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"school"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'educ',
    'uni',
    '',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"amenity":"college"}' or 
    tags @> '{"amenity":"university"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'tran',
    'fte',
    'ferryterminal',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"ferry_terminal"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'tran',
    'fer',
    'ferryroute',
    tags ->> 'route',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"route":"ferry"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'tran',
    'por',
    'port',
    COALESCE(tags ->> 'landuse', tags ->> 'industrial'),
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"landuse":"port"}' or
    tags @> '{"landuse":"harbour"}' or
    tags @> '{"industrial":"port"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'cash',
    'bnk',
    'bank',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"bank"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'cash',
    'atm',
    'atm',
    'atm',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"atm":"yes"}' or
    tags @> '{"amenity":"atm"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'heal',
    'hea',
    'healthcentres',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"amenity":"clinic"}' or
    tags @> '{"amenity":"doctors"}' or
    tags @> '{"amenity":"health_post"}' or
    tags @> '{"amenity":"hospital"}' or
    tags @> '{"amenity":"pharmacy"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'heal',
    'hos',
    'hospital',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"hospital"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'cash',
    'mkt',
    'marketplace',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"marketplace"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'cccm',
    'ref',
    'refugeesite',
    tags ->> 'amenity',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"refugee_site"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'tran',
    'brg',
    'bridge',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"bridge":"yes"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'util',
    'ppl',
    'pipeline',
    '',
    'line',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    tags @> '{"man_made":"pipeline"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'util',
    'pwl',
    'powerline',
    '',
    'line',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    tags @> '{"power":"line"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'util',
    'pst',
    'powerstation',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"power":"plant"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'util',
    'pst',
    'substation',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"power":"substation"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'phys',
    'lak',
    'lake',
    '',
    'polygon',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    (tags @> '{"water":"lake"}' or
    tags @> '{"water":"reservoir"}')
    and geometrytype(geog) ~* 'polygon';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'phys',
    'riv',
    'river',
    '',
    'polygon',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    tags @> '{"water":"river"}'
    and geometrytype(geog) ~* 'polygon';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'phys',
    'riv',
    'river',
    '',
    'line',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    tags @> '{"water":"river"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'tran',
    'can',
    'canal',
    '',
    'line',
    geog::geometry as geom
from lgudyma.osm_cnt
where 
    tags @> '{"water":"canal"}'
    and geometrytype(geog) ~* 'linestring';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'pois',
    'rel',
    'placeofworship',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"place_of_worship"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'pois',
    'bor',
    'bordercrossing',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"border":"border_control"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'stle',
    'stl',
    'settlements',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"place":"city"}' or
    tags @> '{"place":"borough"}' or
    tags @> '{"place":"town"}' or
    tags @> '{"place":"village"}' or
    tags @> '{"place":"hamlet"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'stle',
    'stle',
    'settlements',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where 
    tags @> '{"place":"city"}' or
    tags @> '{"place":"town"}';

-- 
insert into lgudyma.mapaction(ma_category, ma_theme, ma_tag, fclass, feature_type, geom) --, osm_minimum_tags
select 'wash',
    'toi',
    '',
    '',
    'point',
    case when geometrytype(geog::geometry) != 'POINT' then st_centroid(geog::geometry) else geog::geometry end as geom
from lgudyma.osm_cnt
where tags @> '{"amenity":"toilet"}';

-- -- 
-- UPDATE lgudyma.mapaction
-- SET country_code = iso_code
-- FROM (select tags ->> 'ISO3166-1:alpha3' as iso_code
--     FROM lgudyma.osm_cnt
--     where kontur_admin_level = 2
--         and tags ? 'ISO3166-1:alpha3'
--     limit 1)
