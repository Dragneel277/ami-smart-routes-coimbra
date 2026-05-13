/* Test routes for different traffic conditions
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

/* Test total cost for different traffic conditions
SELECT 'normal' AS scenario, MAX(agg_cost) AS total_cost
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT 'morning' AS scenario, MAX(agg_cost) AS total_cost
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
);

SELECT 'evening' AS scenario, MAX(agg_cost) AS total_cost
FROM pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
);
    */

SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;

SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;

SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;