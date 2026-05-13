-- ============================================================
-- Context-aware support tables
-- Project: AMI Smart Routes Coimbra
-- Database: smart_routes
-- Purpose:
--   Adds temporal scenarios, manual route requests, and
--   contextual urban reports to support the Profile 1 project
--   with a time/context-aware extension.
-- ============================================================

CREATE TABLE IF NOT EXISTS routing_scenarios (
    scenario_id SERIAL PRIMARY KEY,
    scenario_name TEXT NOT NULL UNIQUE,
    start_hour INTEGER,
    end_hour INTEGER,
    cost_field TEXT NOT NULL,
    reverse_cost_field TEXT NOT NULL,
    description TEXT
);

INSERT INTO routing_scenarios 
(scenario_name, start_hour, end_hour, cost_field, reverse_cost_field, description)
VALUES
('normal', NULL, NULL, 'cost_normal', 'reverse_cost_normal', 'Normal traffic period'),
('morning', 7, 10, 'cost_morning', 'reverse_cost_morning', 'Morning rush hour'),
('evening', 17, 20, 'cost_evening', 'reverse_cost_evening', 'Evening rush hour'),
('dynamic', NULL, NULL, 'cost', 'reverse_cost', 'Current-time dynamic routing')
ON CONFLICT (scenario_name) DO NOTHING;


CREATE TABLE IF NOT EXISTS route_requests (
    request_id SERIAL PRIMARY KEY,
    origin_name TEXT NOT NULL,
    destination_name TEXT NOT NULL,
    origin_geom GEOMETRY(Point, 4326) NOT NULL,
    destination_geom GEOMETRY(Point, 4326) NOT NULL,
    request_hour INTEGER CHECK (request_hour BETWEEN 0 AND 23),
    scenario_id INTEGER REFERENCES routing_scenarios(scenario_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_route_requests_origin_geom
ON route_requests USING GIST (origin_geom);

CREATE INDEX IF NOT EXISTS idx_route_requests_destination_geom
ON route_requests USING GIST (destination_geom);


CREATE TABLE IF NOT EXISTS context_reports (
    report_id SERIAL PRIMARY KEY,
    report_type TEXT NOT NULL,
    description TEXT,
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    geom GEOMETRY(Point, 4326) NOT NULL,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source TEXT DEFAULT 'manual'
);

CREATE INDEX IF NOT EXISTS idx_context_reports_geom
ON context_reports USING GIST (geom);


-- ============================================================
-- Example/test data
-- ============================================================

INSERT INTO route_requests
(origin_name, destination_name, origin_geom, destination_geom, request_hour, scenario_id)
VALUES
(
    'ISEC',
    'Coimbra City Center',
    ST_SetSRID(ST_Point(-8.411633, 40.192922), 4326),
    ST_SetSRID(ST_Point(-8.429205, 40.211491), 4326),
    8,
    (SELECT scenario_id FROM routing_scenarios WHERE scenario_name = 'morning')
),
(
    'ISEC',
    'Coimbra-B Station',
    ST_SetSRID(ST_Point(-8.411633, 40.192922), 4326),
    ST_SetSRID(ST_Point(-8.4320, 40.2250), 4326),
    18,
    (SELECT scenario_id FROM routing_scenarios WHERE scenario_name = 'evening')
)
ON CONFLICT DO NOTHING;


INSERT INTO context_reports
(report_type, description, severity, geom, source)
VALUES
(
    'congestion',
    'Simulated congestion near Coimbra city center',
    4,
    ST_SetSRID(ST_Point(-8.429205, 40.211491), 4326),
    'manual'
),
(
    'road_work',
    'Simulated road works affecting circulation',
    3,
    ST_SetSRID(ST_Point(-8.416700, 40.203300), 4326),
    'manual'
),
(
    'danger_zone',
    'Simulated dangerous crossing near ISEC area',
    5,
    ST_SetSRID(ST_Point(-8.411633, 40.192922), 4326),
    'manual'
);