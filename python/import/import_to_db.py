import os
from pathlib import Path
from urllib.parse import quote_plus

import geopandas as gpd
from sqlalchemy import create_engine


PROJECT_ROOT = Path(__file__).resolve().parents[2]
GEOJSON_PATH = PROJECT_ROOT / "data" / "raw" / "roads_coimbra.geojson"

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "smart_routes")

# Safer default: import into a test table.
# Set DB_TABLE=roads_raw only when you intentionally want to rebuild the
# working raw roads table used by the current PostGIS/pgRouting/QGIS setup.
DB_TABLE = os.getenv("DB_TABLE", "roads_raw_test")

# WARNING: if_exists="replace" drops/recreates the destination table.
# This is acceptable for roads_raw_test, but dangerous for roads_raw unless
# you are deliberately rebuilding the database from the GeoJSON file.
IF_EXISTS = os.getenv("DB_IF_EXISTS", "replace")


def build_database_url() -> str:
    user = quote_plus(DB_USER)
    password = quote_plus(DB_PASSWORD)

    if password:
        auth = f"{user}:{password}"
    else:
        auth = user

    return f"postgresql://{auth}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


if not GEOJSON_PATH.exists():
    raise FileNotFoundError(f"GeoJSON not found: {GEOJSON_PATH}")

engine = create_engine(build_database_url())
gdf = gpd.read_file(GEOJSON_PATH)
gdf.to_postgis(DB_TABLE, engine, if_exists=IF_EXISTS)

print(f"Data imported successfully into table '{DB_TABLE}'.")
