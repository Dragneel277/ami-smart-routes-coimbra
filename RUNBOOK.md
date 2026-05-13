# Runbook

Operational commands for the Coimbra smart routes practical project.

## Start PostgreSQL

Check and start the Windows PostgreSQL service:

```powershell
Get-Service postgresql-x64-18
Start-Service postgresql-x64-18
```

If the service is already running, `Start-Service` may report that no action is needed.

## Connect With psql

```powershell
psql -U postgres -d smart_routes
```

Useful `psql` commands:

```sql
\conninfo
\dt public.*
\dv public.*
\d public.roads
```

## Verify PostGIS and pgRouting

```sql
SELECT postgis_full_version();
SELECT pgr_version();
```

Both commands should return version information. If either fails, the extension is missing or not enabled in `smart_routes`.

## Inspect Current Tables and Views

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;
```

## Safe Python Import Test

The importer reads:

```text
data/raw/roads_coimbra.geojson
```

Create a local `.env` from `.env.example` or set variables in PowerShell:

```powershell
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "your_password"
$env:DB_HOST = "localhost"
$env:DB_PORT = "5432"
$env:DB_NAME = "smart_routes"
$env:DB_TABLE = "roads_raw_test"
$env:DB_IF_EXISTS = "replace"
python python/import/import_to_db.py
```

Use `DB_TABLE=roads_raw` only when intentionally rebuilding the working raw table. With `DB_IF_EXISTS=replace`, the destination table is overwritten.

## Rebuild Warning

Some SQL files contain `DROP TABLE IF EXISTS public.roads` or overwrite dynamic cost columns. Review each script before running it against `smart_routes`.

Recommended manual flow before any rebuild:

```sql
\dt public.*
\dv public.*
SELECT COUNT(*) FROM public.roads_raw;
SELECT COUNT(*) FROM public.roads;
```

Create a database backup outside the repository before destructive rebuilds.
