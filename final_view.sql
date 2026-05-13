CREATE OR REPLACE VIEW route_normal_real AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  (
    SELECT source
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.42, 40.21), 4326)
    LIMIT 1
  ),
  (
    SELECT target
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.40, 40.23), 4326)
    LIMIT 1
  )
) d
ON r.id = d.edge
WHERE d.edge <> -1;

CREATE OR REPLACE VIEW route_morning_real AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  (
    SELECT source
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.42, 40.21), 4326)
    LIMIT 1
  ),
  (
    SELECT target
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.40, 40.23), 4326)
    LIMIT 1
  )
) d
ON r.id = d.edge
WHERE d.edge <> -1;

CREATE OR REPLACE VIEW route_evening_real AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  (
    SELECT source
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.42, 40.21), 4326)
    LIMIT 1
  ),
  (
    SELECT target
    FROM public.roads
    ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.40, 40.23), 4326)
    LIMIT 1
  )
) d
ON r.id = d.edge
WHERE d.edge <> -1;