/*
--check values
SELECT source
FROM public.roads
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.42, 40.21), 4326)
LIMIT 1;



SELECT target
FROM public.roads
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-8.40, 40.23), 4326)
LIMIT 1;

*/

SELECT * FROM pgr_dijkstra(
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
);

SELECT * FROM pgr_dijkstra(
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
);

SELECT * FROM pgr_dijkstra(
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
);