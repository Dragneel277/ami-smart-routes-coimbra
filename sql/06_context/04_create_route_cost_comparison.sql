-- ============================================================
-- Route cost comparison view
-- Project: AMI Smart Routes Coimbra
-- Database: smart_routes
--
-- Purpose:
--   Adds a metric length field and exposes the difference between
--   normal, morning and evening routing costs.
--
-- Notes:
--   - length_meters is calculated from geometry using PostGIS.
--   - cost_normal is the base routing cost.
--   - cost_morning and cost_evening are simulated time-based costs.
--   - morning_increase_percent and evening_increase_percent help
--     explain the temporal/context-aware layer.
-- ============================================================

ALTER TABLE roads
ADD COLUMN IF NOT EXISTS length_meters DOUBLE PRECISION;

UPDATE roads
SET length_meters = ST_Length(geom::geography);

DROP VIEW IF EXISTS route_cost_comparison;

CREATE VIEW route_cost_comparison AS
SELECT
    id,
    source,
    target,
    highway,
    oneway,
    ROUND(length_meters::numeric, 2) AS length_meters,
    cost_normal,
    cost_morning,
    cost_evening,
    cost_weekend,
    ROUND((cost_morning - cost_normal)::numeric, 6) AS morning_extra_cost,
    ROUND((cost_evening - cost_normal)::numeric, 6) AS evening_extra_cost,
    ROUND(
        CASE 
            WHEN cost_normal > 0 THEN ((cost_morning - cost_normal) / cost_normal * 100)::numeric
            ELSE 0
        END,
        2
    ) AS morning_increase_percent,
    ROUND(
        CASE 
            WHEN cost_normal > 0 THEN ((cost_evening - cost_normal) / cost_normal * 100)::numeric
            ELSE 0
        END,
        2
    ) AS evening_increase_percent,
    CASE
        WHEN cost_morning > cost_normal THEN 'higher in morning'
        ELSE 'same or lower'
    END AS morning_effect,
    CASE
        WHEN cost_evening > cost_normal THEN 'higher in evening'
        ELSE 'same or lower'
    END AS evening_effect,
    geom
FROM roads;
