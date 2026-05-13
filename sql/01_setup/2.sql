CREATE OR REPLACE VIEW route_normal AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_normal AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;

CREATE OR REPLACE VIEW route_morning AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_morning AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;

CREATE OR REPLACE VIEW route_evening AS
SELECT r.*
FROM public.roads r
JOIN pgr_dijkstra(
  'SELECT id, source, target, cost_evening AS cost FROM public.roads',
  1330356313,
  2597844234
) d
ON r.id = d.edge
WHERE d.edge <> -1;

SELECT * FROM route_morning;