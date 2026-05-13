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