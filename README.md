# AMI Smart Routes Coimbra

Time-sensitive intelligent route recommendation system for Coimbra.

This practical project uses PostgreSQL, PostGIS, pgRouting, QGIS, and Python to compare route recommendations under different time contexts:

- normal period
- morning rush hour
- evening rush hour
- dynamic/current-time routing

The current working database is `smart_routes`. It contains the working road network and route layers used by QGIS.

## Repository Structure

```text
sql/
  00_checks/        Database inspection and route test queries
  01_setup/         Setup/build helper SQL
  02_import/        Import/rebuild SQL for road tables
  03_routing/       pgRouting experiments and route queries
  04_dynamic_costs/ Time-dependent cost function and traffic cost scripts
  05_views/         QGIS-facing route and road views
  99_old/           Older or experimental SQL kept for reference
python/
  download/         OSMnx download scripts
  import/           GeoJSON-to-PostGIS import scripts
qgis/               QGIS project files
data/
  raw/              Source GeoJSON data
  processed/        Exports/results
docs/               Images and supporting documentation assets
```

## Important Safety Notes

Do not run rebuild/import scripts against the working database unless you intend to overwrite tables.

The table `roads_raw` is the raw PostGIS import used to build the working network. The Python importer defaults to `roads_raw_test` to avoid accidentally replacing it.

The table `roads` and views such as `roads_directed`, `roads_dynamic`, and `route_*` are part of the current QGIS/pgRouting workflow. Preserve them unless intentionally rebuilding the full system.

## Quick Start

Start PostgreSQL on Windows:

```powershell
Get-Service postgresql-x64-18
Start-Service postgresql-x64-18
```

Connect with `psql`:

```powershell
psql -U postgres -d smart_routes
```

Verify extensions:

```sql
SELECT postgis_full_version();
SELECT pgr_version();
```

List tables and views:

```sql
\dt public.*
\dv public.*
```

Expected core tables include `roads_raw`, `roads`, and `roads_vertices`. Expected QGIS-facing route layers include `route_normal`, `route_morning`, `route_evening`, `route_dynamic_real`, `route_normal_real`, `route_morning_real`, and `route_evening_real`.

See [RUNBOOK.md](RUNBOOK.md), [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md), [QGIS_GUIDE.md](QGIS_GUIDE.md), and [CURRENT_STATUS.md](CURRENT_STATUS.md) for detailed operational notes.
