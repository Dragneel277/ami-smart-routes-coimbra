CREATE OR REPLACE VIEW public.roads_directed AS
SELECT
    id,
    source,
    target,
    geom,
    cost_normal AS cost,
    CASE
        WHEN lower(oneway) = 'true' THEN -1
        ELSE cost_normal
    END AS reverse_cost
FROM public.roads;