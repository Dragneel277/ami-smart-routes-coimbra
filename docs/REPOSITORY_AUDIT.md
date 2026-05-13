# Repository Audit

Short audit based on inspected files and metadata.

## Root

- `.gitignore`: Git ignore rules for Python, QGIS backups, database dumps, editor files, OS files, and caches.
- `.env`: local environment/secret file. Left unchanged and ignored by Git.
- `.env.example`: safe placeholder environment variables for the importer.
- `README.md`: project overview and quick start.
- `CURRENT_STATUS.md`: current known working database/QGIS state.
- `RUNBOOK.md`: operational commands and safety notes.
- `DATABASE_SCHEMA.md`: expected database tables, views, and verification queries.
- `QGIS_GUIDE.md`: QGIS connection and expected layer guide.

## Data

- `data/raw/roads_coimbra.geojson`: raw OSMnx road network GeoJSON for Coimbra.
- `data/processed/result_export.csv`: empty processed/export placeholder.
- `docs/route_dynamic_real_qgis.png`: QGIS route visualization/export.

## Python

- `python/download/download_coimbra.py`: downloads Coimbra drive network with OSMnx and writes GeoJSON to `data/raw/`.
- `python/import/import_to_db.py`: imports `data/raw/roads_coimbra.geojson` into PostGIS using environment variables.

## QGIS

- `qgis/Final_working.qgz`: QGIS project containing OSM and route layers including `route_dynamic_real` and real route variants.
- `qgis/Project.qgz`: QGIS project containing OSM and normal/morning/evening route layers.

## SQL Checks

- `sql/00_checks/check_currrent_db.sql`: rebuild-style check/build script for `roads` from `roads_raw`; review before running because it drops `roads`.
- `sql/00_checks/check_final.sql`: selects from `roads_directed`.
- `sql/00_checks/check_roads.sql`: samples `roads`.
- `sql/00_checks/check_roads_raw.sql`: lists `roads_raw` columns.
- `sql/00_checks/first_route_test.sql`: test pgRouting queries for normal, morning, and evening costs.
- `sql/00_checks/morecmd.sql`: simple `roads` sampling query.
- `sql/00_checks/test_routes.sql`: route test queries for fixed source/target nodes and different costs.

## SQL Setup and Import

- `sql/01_setup/commands.sql`: creates `roads_vertices`, spatial indexes, and updates `roads.source`/`roads.target`.
- `sql/02_import/recreate_roads.sql`: rebuilds `roads` from `roads_raw` using OSM `u`/`v` as pgRouting source/target ids.

## SQL Routing and Dynamic Costs

- `sql/03_routing/after_map.sql`: pgRouting tests using nearest edges to coordinate pairs.
- `sql/03_routing/change_pgrouting.sql`: creates a simplified directed road view with reverse costs for one-way roads.
- `sql/03_routing/Final_Comp.sql`: compares total route costs for normal, morning, and evening scenarios.
- `sql/04_dynamic_costs/Latest.sql`: defines `get_time_cost(...)`, creates `roads_dynamic`, and tests dynamic routing.
- `sql/04_dynamic_costs/simulate_traffic.sql`: updates morning/evening costs based on road `highway` type.

## SQL Views

- `sql/05_views/final_version_include_all.sql`: creates `roads_directed` with normal, morning, evening, and current dynamic reverse costs.
- `sql/05_views/final_view.sql`: creates real route views for normal, morning, and evening route variants.
- `sql/05_views/route_views_fixed_nodes.sql`: creates fixed-node `route_normal`, `route_morning`, and `route_evening` views.

## Old or Experimental SQL

- `sql/99_old/1.sql`: commented route/cost experiments.
- `sql/99_old/Create_Dynamic_Cost.sql`: earlier simplified `roads_directed` view.
- `sql/99_old/build_roads.sql`: earlier `roads` rebuild script with null source/target columns.
- `sql/99_old/cmdsv2.sql`: partial target update query.
- `sql/99_old/roads.sql`: scratch/import SQL with mostly commented rebuild attempts and index creation.

## Cache

- `cache/*.json`: OSMnx/geocoding cache artifacts. Kept in place, now ignored for future cache files.
