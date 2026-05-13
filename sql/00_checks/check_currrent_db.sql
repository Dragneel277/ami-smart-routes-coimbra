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

SELECT id, source, target, cost_normal
FROM public.roads
LIMIT 10;

CREATE INDEX roads_geom_idx
ON public.roads
USING GIST (geom);