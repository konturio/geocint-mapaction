drop table if exists :tablename;
create table :tablename
(
    geog      geography,
    osm_type  text,
    osm_id    bigint,
    tags      jsonb
);

