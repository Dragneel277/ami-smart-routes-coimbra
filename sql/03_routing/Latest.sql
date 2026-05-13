CREATE OR REPLACE FUNCTION get_time_cost(
    hour_input INTEGER,
    cost_normal DOUBLE PRECISION,
    cost_morning DOUBLE PRECISION,
    cost_evening DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS
$$
BEGIN
    -- Morning rush hour (7h - 10h)
    IF hour_input BETWEEN 7 AND 10 THEN
        RETURN cost_morning;

    -- Evening rush hour (17h - 20h)
    ELSIF hour_input BETWEEN 17 AND 20 THEN
        RETURN cost_evening;

    -- Otherwise normal
    ELSE
        RETURN cost_normal;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE VIEW roads_dynamic AS
SELECT
    id,
    source,
    target,
    geom,
    get_time_cost(
        EXTRACT(HOUR FROM NOW())::INTEGER,
        cost_normal,
        cost_morning,
        cost_evening
    ) AS cost
FROM public.roads;

SELECT * FROM roads_dynamic LIMIT 10;

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost FROM roads_dynamic',
  132839117,
  1655345512
);