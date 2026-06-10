-- ============================================================
-- MerginMaps-ready mobile observation layer
-- Project: AMI Smart Routes Coimbra
-- Database: smart_routes
--
-- Purpose:
--   Adds an editable field-collection table and routing bridge
--   views for observations collected through MerginMaps/QGIS.
--
-- Workflow:
--   MerginMaps collects field points
--   QGIS syncs those points
--   PostGIS stores them
--   pgRouting can later use them as contextual road penalties
-- ============================================================

CREATE TABLE IF NOT EXISTS mobile_observations (
    observation_id SERIAL PRIMARY KEY,
    observation_type TEXT NOT NULL,
    description TEXT,
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    confidence INTEGER CHECK (confidence BETWEEN 1 AND 5),
    reported_by TEXT,
    source_project TEXT DEFAULT 'MerginMaps',
    observed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    geom GEOMETRY(Point, 4326) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_mobile_observations_geom
ON mobile_observations USING GIST (geom);

ALTER TABLE roads
ADD COLUMN IF NOT EXISTS length_meters DOUBLE PRECISION;

UPDATE roads
SET length_meters = ST_Length(geom::geography)
WHERE length_meters IS NULL;

-- ============================================================
-- Example/test data for MerginMaps workflow validation
-- ============================================================

WITH sample_observations (
    observation_type,
    description,
    severity,
    confidence,
    reported_by,
    geom
) AS (
    VALUES
    (
        'congestion',
        'Manual test observation for MerginMaps workflow',
        4,
        4,
        'Ruben',
        ST_SetSRID(ST_Point(-8.429205, 40.211491), 4326)
    ),
    (
        'event',
        'Possible event affecting routes',
        3,
        3,
        'Ruben',
        ST_SetSRID(ST_Point(-8.421000, 40.205000), 4326)
    ),
    (
        'danger_zone',
        'Dangerous crossing or problematic area',
        5,
        4,
        'Ruben',
        ST_SetSRID(ST_Point(-8.411633, 40.192922), 4326)
    )
)
INSERT INTO mobile_observations
(observation_type, description, severity, confidence, reported_by, geom)
SELECT
    so.observation_type,
    so.description,
    so.severity,
    so.confidence,
    so.reported_by,
    so.geom
FROM sample_observations so
WHERE NOT EXISTS (
    SELECT 1
    FROM mobile_observations mo
    WHERE mo.observation_type = so.observation_type
      AND mo.description = so.description
      AND mo.reported_by = so.reported_by
      AND ST_Equals(mo.geom, so.geom)
);

-- ============================================================
-- Field observations converted into routing penalty multipliers
-- ============================================================

CREATE OR REPLACE VIEW mobile_context_penalties AS
SELECT
    observation_id,
    observation_type,
    severity,
    confidence,
    CASE
        WHEN observation_type = 'blocked_road' THEN 5.0
        WHEN observation_type = 'accident' THEN 3.0
        WHEN observation_type = 'road_work' THEN 2.0
        WHEN observation_type = 'congestion' THEN 1.5
        WHEN observation_type = 'danger_zone' THEN 1.3
        WHEN observation_type = 'event' THEN 1.2
        ELSE 1.0
    END AS penalty_multiplier,
    geom
FROM mobile_observations;

-- ============================================================
-- Roads affected by nearby mobile field observations
-- ============================================================

CREATE OR REPLACE VIEW roads_near_mobile_context AS
SELECT
    r.id AS road_id,
    r.highway,
    r.oneway,
    r.length_meters,
    mo.observation_id,
    mo.observation_type,
    mo.severity,
    mo.confidence,
    mp.penalty_multiplier,
    ST_Distance(r.geom::geography, mo.geom::geography) AS distance_meters,
    r.geom
FROM roads r
JOIN mobile_observations mo
    ON ST_DWithin(r.geom::geography, mo.geom::geography, 50)
JOIN mobile_context_penalties mp
    ON mo.observation_id = mp.observation_id;

-- ============================================================
-- Verification queries
-- ============================================================

SELECT
    observation_id,
    observation_type,
    severity,
    confidence,
    reported_by,
    ST_AsText(geom) AS geom
FROM mobile_observations
ORDER BY observation_id;

SELECT
    road_id,
    observation_type,
    severity,
    confidence,
    penalty_multiplier,
    ROUND(distance_meters::numeric, 2) AS distance_meters
FROM roads_near_mobile_context
ORDER BY distance_meters
LIMIT 20;
