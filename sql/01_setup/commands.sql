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

SELECT id, source, target, cost_normal, cost_morning, cost_evening, cost_weekend
FROM public.roads
LIMIT 10;