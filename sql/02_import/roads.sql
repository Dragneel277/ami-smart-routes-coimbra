/*
-- crate Roads
DROP TABLE IF EXISTS public.roads;

CREATE TABLE public.roads AS
SELECT
    row_number() OVER () AS id,
    geometry AS geom,
    ST_Length(geometry) AS length,
    ST_Length(geometry) AS cost_normal,
    ST_Length(geometry) * 1.5 AS cost_morning,
    ST_Length(geometry) * 1.3 AS cost_evening,
    ST_Length(geometry) AS cost_weekend,
    NULL::BIGINT AS source,
    NULL::BIGINT AS target
FROM public.roads_raw
WHERE geometry IS NOT NULL;
*/

/*
-- Check the number of roads
SELECT COUNT(*) AS roads_count
FROM public.roads;
*/

/*
DROP TABLE IF EXISTS public.roads_vertices;

CREATE TABLE public.roads_vertices AS
WITH pts AS (
    SELECT ST_StartPoint(geom) AS geom FROM public.roads
    UNION ALL
    SELECT ST_EndPoint(geom) AS geom FROM public.roads
),
dedup AS (
    SELECT DISTINCT ST_AsText(geom) AS wkt, geom
    FROM pts
)
SELECT
    row_number() OVER () AS id,
    geom
FROM dedup;
*/

/*
CREATE INDEX roads_geom_idx
ON public.roads
USING GIST (geom);

CREATE INDEX roads_vertices_geom_idx
ON public.roads_vertices
USING GIST (geom);

UPDATE public.roads r
SET source = v.id
FROM public.roads_vertices v
WHERE ST_Equals(ST_StartPoint(r.geom), v.geom);

UPDATE public.roads r
SET target = v.id
FROM public.roads_vertices v
WHERE ST_Equals(ST_EndPoint(r.geom), v.geom);
*/

/*
--Recreate Roads After Fail
DROP TABLE IF EXISTS public.roads;

CREATE TABLE public.roads AS
SELECT
    row_number() OVER () AS id,
    geometry AS geom,
    u::BIGINT AS source,
    v::BIGINT AS target,
    ST_Length(geometry) AS length,
    ST_Length(geometry) AS cost_normal,
    ST_Length(geometry) * 1.5 AS cost_morning,
    ST_Length(geometry) * 1.3 AS cost_evening,
    ST_Length(geometry) AS cost_weekend
FROM public.roads_raw
WHERE geometry IS NOT NULL
  AND u IS NOT NULL
  AND v IS NOT NULL;
*/

/* --Check the roads table 
SELECT id, source, target, cost_normal
FROM public.roads
LIMIT 10;
*/

CREATE INDEX roads_geom_idx
ON public.roads
USING GIST (geom);