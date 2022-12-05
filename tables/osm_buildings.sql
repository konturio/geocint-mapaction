drop table if exists osm_buildings;
create table osm_buildings as ( --tablespace evo4tb as (
    select osm_type,
           osm_id,
           geog::geometry as geom,
           tags
    from osm o
    where tags ? 'building'
      and not tags @> '{"building":"no"}'
    order by _ST_SortableHash(geog::geometry)
);

alter table osm_buildings set (parallel_workers=32); -- critical path

create index on osm_buildings using brin (geom); -- order by _ST_SortableHash
