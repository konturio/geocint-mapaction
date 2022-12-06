drop table if exists mapaction_data;

create table mapaction_data(id bigserial primary key,
    country_code text,
    ma_category text,
    ma_theme text,
    ma_tag text,
    fclass text,
    feature_type text,
    osm_minimum_tags jsonb,
    geom geometry(geometry, 4326));

