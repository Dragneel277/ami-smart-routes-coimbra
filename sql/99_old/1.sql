/*
SELECT source, target
FROM public.roads
ORDER BY random()
LIMIT 5;

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
);
 */

/*
SELECT max(agg_cost) AS total_cost_normal
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT max(agg_cost) AS total_cost_morning
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT max(agg_cost) AS total_cost_evening
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
);
*/

/*
SELECT edge
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
)
WHERE edge <> -1;

SELECT edge
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
)
WHERE edge <> -1;

SELECT edge
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
)
WHERE edge <> -1;
*/

SELECT id, cost_normal, cost_morning, cost_evening
FROM public.roads
LIMIT 10;

/**/

/**/
