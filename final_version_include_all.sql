CREATE VIEW public.roads_directed AS
SELECT
    id,
    source,
    target,
    geom,

    cost_normal,
    cost_morning,
    cost_evening,

    get_time_cost(
        EXTRACT(HOUR FROM NOW())::INTEGER,
        cost_normal,
        cost_morning,
        cost_evening
    ) AS cost,

    CASE
        WHEN lower(oneway) = 'true' THEN -1
        ELSE cost_normal
    END AS reverse_cost_normal,

    CASE
        WHEN lower(oneway) = 'true' THEN -1
        ELSE cost_morning
    END AS reverse_cost_morning,

    CASE
        WHEN lower(oneway) = 'true' THEN -1
        ELSE cost_evening
    END AS reverse_cost_evening,

    CASE
        WHEN lower(oneway) = 'true' THEN -1
        ELSE get_time_cost(
            EXTRACT(HOUR FROM NOW())::INTEGER,
            cost_normal,
            cost_morning,
            cost_evening
        )
    END AS reverse_cost

FROM public.roads;