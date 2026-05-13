-- QGIS-friendly views for route request origin and destination points

CREATE OR REPLACE VIEW route_request_origins AS
SELECT
    request_id,
    origin_name AS name,
    destination_name,
    request_hour,
    scenario_id,
    origin_geom AS geom
FROM route_requests;

CREATE OR REPLACE VIEW route_request_destinations AS
SELECT
    request_id,
    destination_name AS name,
    origin_name,
    request_hour,
    scenario_id,
    destination_geom AS geom
FROM route_requests;
