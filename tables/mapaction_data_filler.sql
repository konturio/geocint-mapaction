with code as (select tags ->> 'ISO3166-1:alpha3' as country_code from :osm_table where tags ->> 'ISO3166-1:alpha3' is not null limit 1)
insert into :ma_table(country_code, ma_category, ma_theme, ma_tag, fclass, feature_type, geom)
select code.country_code,
'tran',
    'rds',
    'roads',
    tags ->> 'highway',
    'line',
    geog::geometry as geom
from code, :osm_table
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


with code as (select tags ->> 'ISO3166-1:alpha3' as country_code from :osm_table where tags ->> 'ISO3166-1:alpha3' is not null limit 1)
insert into :ma_table(country_code, ma_category, ma_theme, ma_tag, fclass, feature_type, geom)
select code.country_code,
'tran',
    'rds',
    'mainroads',
    replace(tags ->> 'highway', '_link', '' ),
    'line',
    geog::geometry as geom
from code, :osm_table
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

