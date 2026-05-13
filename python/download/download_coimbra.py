import osmnx as ox
from pathlib import Path

place = "Coimbra, Portugal"
project_root = Path(__file__).resolve().parents[2]
output_path = project_root / "data" / "raw" / "roads_coimbra.geojson"

print("Downloading road network...")
G = ox.graph_from_place(place, network_type="drive")

print("Converting graph to GeoDataFrame...")
gdf_edges = ox.graph_to_gdfs(G, nodes=False)

print("Saving to GeoJSON...")
output_path.parent.mkdir(parents=True, exist_ok=True)
gdf_edges.to_file(output_path, driver="GeoJSON")

print(f"Done: {output_path} created")
