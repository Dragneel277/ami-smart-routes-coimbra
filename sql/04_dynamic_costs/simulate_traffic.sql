UPDATE public.roads
SET cost_morning = CASE
    WHEN highway LIKE '%primary%' THEN cost_normal * 4
    WHEN highway LIKE '%secondary%' THEN cost_normal * 3
    WHEN highway LIKE '%tertiary%' THEN cost_normal * 2
    ELSE cost_normal * 1.2
END;

UPDATE public.roads
SET cost_evening = CASE
    WHEN highway LIKE '%primary%' THEN cost_normal * 3
    WHEN highway LIKE '%secondary%' THEN cost_normal * 2
    ELSE cost_normal * 1.1
END;