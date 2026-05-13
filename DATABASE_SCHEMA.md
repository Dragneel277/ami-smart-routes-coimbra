# Database Schema

Database name: `smart_routes`

This document describes the expected working objects for the practical system. It is not a generated schema dump.

## Core Tables

`roads_raw`

Raw road network imported from `data/raw/roads_coimbra.geojson`. This table should not be overwritten accidentally.

`roads`

Processed routing edge table. Expected columns include:

- `id`
- `geom`
- `source`
- `target`
- `highway`
- `length`
- `cost_normal`
- `cost_morning`
- `cost_evening`
- `cost_weekend`

`roads_vertices`

Vertex table used by pgRouting and source/target validation.

## Routing Views

`roads_directed`

Road edge view with forward and reverse costs. One-way roads should receive a blocked reverse cost, commonly `-1`.

`roads_dynamic`

Dynamic edge view using `get_time_cost(...)` to select the active cost from the current hour.

`roads_plugin`

QGIS/plugin-facing road layer if present in the working database.

## Route Layers

Expected route layers/views:

- `route_normal`
- `route_morning`
- `route_evening`
- `route_dynamic_real`
- `route_normal_real`
- `route_morning_real`
- `route_evening_real`

These are the layers that should appear in QGIS when connected to `smart_routes`.

## Verification Queries

```sql
SELECT COUNT(*) FROM public.roads_raw;
SELECT COUNT(*) FROM public.roads;
SELECT COUNT(*) FROM public.roads_vertices;

SELECT *
FROM public.roads_directed
LIMIT 5;

SELECT *
FROM public.roads_dynamic
LIMIT 5;
```

Check route layers:

```sql
SELECT COUNT(*) FROM public.route_normal_real;
SELECT COUNT(*) FROM public.route_morning_real;
SELECT COUNT(*) FROM public.route_evening_real;
```

## Rebuild Warning

`roads_raw` and `roads` are central working tables. Scripts that use `if_exists="replace"` or `DROP TABLE IF EXISTS` can break the current QGIS project if run unintentionally.
