SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  (SELECT source FROM public.roads LIMIT 1),
  (SELECT target FROM public.roads LIMIT 1)
);

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  (SELECT source FROM public.roads LIMIT 1),
  (SELECT target FROM public.roads LIMIT 1)
);

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  (SELECT source FROM public.roads LIMIT 1),
  (SELECT target FROM public.roads LIMIT 1)
);