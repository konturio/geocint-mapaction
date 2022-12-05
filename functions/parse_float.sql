create or replace function parse_float(val text)
    returns double precision as
$$
select case
           when val ~ '^[-+]?[0-9]*\.?[0-9]+$'
               then val::double precision
           else null
       end
$$
    language 'sql'
    immutable
    parallel safe;