# Current Status

The repository is organized around the current working database `smart_routes`.

## Working Database State

Known working tables:

- `roads_raw`
- `roads`
- `roads_vertices`

Known working views/layers:

- `roads_directed`
- `roads_dynamic`
- `roads_plugin`
- `route_normal`
- `route_morning`
- `route_evening`
- `route_dynamic_real`
- `route_normal_real`
- `route_morning_real`
- `route_evening_real`

## Current Route Logic

The routing model uses multiple costs on the road network:

- `cost_normal` for baseline routing
- `cost_morning` for morning rush hour
- `cost_evening` for evening rush hour
- `cost_weekend` where available

The dynamic route logic selects a cost according to the current hour, with morning and evening rush-hour branches.

## Data and QGIS

Raw road data is stored in `data/raw/roads_coimbra.geojson`.

QGIS projects are stored in `qgis/`:

- `qgis/Final_working.qgz`
- `qgis/Project.qgz`

The inspected QGIS projects reference route layers including normal, morning, evening, and real/dynamic route variants.

## Safety Status

The Python importer now defaults to `roads_raw_test` instead of `roads_raw`.

Scripts that drop or replace tables should be treated as rebuild scripts. Review them before running against `smart_routes`.

The `.env` file is ignored by Git. Do not commit real database credentials.
