import osmnx as ox

place = "Coimbra, Portugal"

print("Downloading road network...")
G = ox.graph_from_place(place, network_type="drive")

print("Converting graph to GeoDataFrame...")
gdf_edges = ox.graph_to_gdfs(G, nodes=False)

print("Saving to GeoJSON...")
gdf_edges.to_file("roads_coimbra.geojson", driver="GeoJSON")

print("Done: roads_coimbra.geojson created")
