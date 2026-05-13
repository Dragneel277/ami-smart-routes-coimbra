CREATE OR REPLACE VIEW roads_directed AS
SELECT
    id,
    source,
    target,
    geom,

    -- forward cost (normal direction)
    cost_normal AS cost,

    -- reverse cost (opposite direction)
    CASE
        WHEN oneway = 'yes' THEN -1   -- block reverse direction
        ELSE cost_normal
    END AS reverse_cost

FROM public.roads;