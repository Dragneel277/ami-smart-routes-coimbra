-- ============================================================
-- Route request + scenario relationship view
-- Project: AMI Smart Routes Coimbra
-- Database: smart_routes
--
-- Purpose:
--   Shows the relationship between manual/simulated route
--   requests and the temporal routing scenarios.
--
-- Relationship:
--   route_requests.scenario_id -> routing_scenarios.scenario_id
-- ============================================================

CREATE OR REPLACE VIEW route_requests_with_scenarios AS
SELECT
    rr.request_id,
    rr.origin_name,
    rr.destination_name,
    rr.request_hour,
    rs.scenario_name,
    rs.cost_field,
    rs.reverse_cost_field,
    rr.created_at,
    rr.origin_geom,
    rr.destination_geom
FROM route_requests rr
JOIN routing_scenarios rs
    ON rr.scenario_id = rs.scenario_id;
