-- this func generates sql string for ogr2ogr
-- if there is additional type for layer it will add this from json column
-- name of the type consists of [ma_category]_[ma_theme]_[ma_tag]_[feature_type]
-- but ma_tag can be empty, need to be checked

-- TODO 
-- * change name of table 
-- * get rid of schema lgudyma
CREATE OR REPLACE FUNCTION mapaction_data_export(
    table_name text, geoextent text, ma_category text, ma_theme text, ma_tag text, feature_type text)
RETURNS text AS
$BODY$
DECLARE
    typeName text := trim(lower(format('%1$s%2$s%3$s%4$s', 
        COALESCE(ma_category, ''), 
        COALESCE(format('_%1$s', ma_theme), ''),
        COALESCE(format('_%1$s', ma_tag), ''),
        COALESCE(format('_%1$s', feature_type), ''))));
    ogrExportQuery text := '';
begin
    --  check if exists type for additional columns for layer and return query
    --  if type does not exist, return simple query
    if exists (select typname from pg_type where typname = typeName) THEN
        select format('SELECT osm_id, osm_type, fclass, v.*, geom
            FROM    %7$I as s, 
                    lateral jsonb_populate_record(null::%1$I, osm_minimum_tags) as v
            where (lower(country_code), lower(ma_category), lower(ma_theme), lower(ma_tag), lower(feature_type)) = 
                (lower(%2$L), lower(%3$L), lower(%4$L), lower(%5$L), lower(%6$L))', 
            typeName, geoextent, ma_category, ma_theme, ma_tag, feature_type, lower(table_name))
        into ogrExportQuery;
    else
        select format('SELECT osm_id, osm_type, fclass, geom
            FROM %6$I
            where (lower(country_code), lower(ma_category), lower(ma_theme), lower(ma_tag), lower(feature_type)) = 
                (lower(%1$L), lower(%2$L), lower(%3$L), lower(%4$L), lower(%5$L))', 
            geoextent, ma_category, ma_theme, ma_tag, feature_type, lower(table_name))
        into ogrExportQuery;
    end if;
    return ogrExportQuery;
END;
$BODY$ 
LANGUAGE plpgsql STABLE COST 100;
