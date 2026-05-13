# QGIS Guide

QGIS project files are stored in `qgis/`.

## Projects

- `qgis/Final_working.qgz`
- `qgis/Project.qgz`

Do not delete these files. They are the current visual entry points for the practical system.

## Connect QGIS to PostgreSQL

In QGIS:

1. Open Browser Panel.
2. Right-click PostgreSQL.
3. Choose New Connection.
4. Use:

```text
Name: smart_routes
Host: localhost
Port: 5432
Database: smart_routes
Username: postgres
Password: your local password
```

Avoid committing saved credentials. Use local QGIS credential storage if needed.

## Expected Layers

The database connection should expose:

- `roads`
- `roads_raw`
- `roads_vertices`
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

The inspected QGIS projects include route layers for normal, morning, evening, and real/dynamic routing.

## Display Checks

After opening a project:

1. Confirm the PostgreSQL connection points to `smart_routes`.
2. Refresh unavailable layers if QGIS asks for credentials.
3. Confirm route layers draw over the OSM basemap.
4. Compare normal, morning, evening, and dynamic routes.

The image `docs/route_dynamic_real_qgis.png` is kept as a visual reference/export from the QGIS workflow.
