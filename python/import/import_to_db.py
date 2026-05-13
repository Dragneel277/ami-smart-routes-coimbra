import geopandas as gpd
from sqlalchemy import create_engine

# Change password here
user = "postgres"
password = "12345"
host = "localhost"
port = "5432"
db = "smart_routes"

engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{db}")

# Load your file
gdf = gpd.read_file("roads_coimbra.geojson")

# Send to database
gdf.to_postgis("roads_raw", engine, if_exists="replace")

print("Data imported successfully!")