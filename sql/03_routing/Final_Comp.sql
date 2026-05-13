SELECT 'normal' AS scenario, MAX(agg_cost) AS total_cost
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
)

UNION

SELECT 'morning', MAX(agg_cost)
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
)

UNION

SELECT 'evening', MAX(agg_cost)
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
);