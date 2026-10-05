import xml.etree.ElementTree as ET
import numpy as np
import csv

input_osm = 'map.osm'
output_osm = 'data/real_roads/delhi_azad_market.osm'
output_csv = 'data/real_roads/delhi_road_centers.csv'

print(f"Reading {input_osm}...")
tree = ET.parse(input_osm)
root = tree.getroot()

# Define bounding box around Rani Jhansi Road / Azad Market junction (~600m x 600m)
# Central point approx: Lat 28.660, Lon 77.210
target_minlat = 28.6550
target_maxlat = 28.6640
target_minlon = 28.2040 # wait, lon is 77.205
target_minlon = 77.2050
target_maxlon = 77.2160

# Find all nodes in target box
selected_nodes = {}
for node in root.findall('node'):
    nid = node.get('id')
    lat = float(node.get('lat'))
    lon = float(node.get('lon'))
    if target_minlat <= lat <= target_maxlat and target_minlon <= lon <= target_maxlon:
        selected_nodes[nid] = (lat, lon)

print(f"Selected {len(selected_nodes)} nodes in focused Azad Market / Rani Jhansi corridor.")

# Find ways that have at least 2 nodes in selected_nodes
selected_ways = []
used_node_ids = set()

for way in root.findall('way'):
    hw = None
    for tag in way.findall('tag'):
        if tag.get('k') == 'highway':
            hw = tag.get('v')
            break
    if not hw:
        continue
    
    nd_refs = [nd.get('ref') for nd in way.findall('nd')]
    valid_refs = [ref for ref in nd_refs if ref in selected_nodes]
    
    # If way has at least 2 connected nodes in the box
    if len(valid_refs) >= 2:
        selected_ways.append(way)
        for ref in valid_refs:
            used_node_ids.add(ref)

print(f"Selected {len(selected_ways)} road ways using {len(used_node_ids)} nodes.")

# Build compact OSM XML
new_root = ET.Element('osm', version="0.6", generator="BharatNav_OSM_Extractor")
bounds = ET.SubElement(new_root, 'bounds', 
                       minlat=str(target_minlat), minlon=str(target_minlon),
                       maxlat=str(target_maxlat), maxlon=str(target_maxlon))

for nid in used_node_ids:
    lat, lon = selected_nodes[nid]
    ET.SubElement(new_root, 'node', id=nid, lat=str(lat), lon=str(lon), version="1")

for way in selected_ways:
    new_root.append(way)

new_tree = ET.ElementTree(new_root)
new_tree.write(output_osm, encoding='utf-8', xml_declaration=True)
print(f"Exported focused OpenStreetMap file: {output_osm} ({len(used_node_ids)} nodes, {len(selected_ways)} ways)")

# Convert the primary corridor (Rani Jhansi Road / Azad Market) into local UTM meters (x, y)
# Reference origin (0, 0)
origin_lat = target_minlat
origin_lon = target_minlon
R = 6371000.0 # Earth radius in meters

def to_meters(lat, lon):
    dlat = np.radians(lat - origin_lat)
    dlon = np.radians(lon - origin_lon)
    mean_lat = np.radians((lat + origin_lat) / 2.0)
    x = R * dlon * np.cos(mean_lat)
    y = R * dlat
    return x, y

# Find longest continuous way to serve as primary ego corridor
best_way = None
best_len = 0
for way in selected_ways:
    nd_refs = [nd.get('ref') for nd in way.findall('nd') if nd.get('ref') in selected_nodes]
    if len(nd_refs) > best_len:
        best_len = len(nd_refs)
        best_way = way

if best_way is not None:
    way_name = "Rani Jhansi Road Corridor"
    for tag in best_way.findall('tag'):
        if tag.get('k') in ['name', 'name:en']:
            way_name = tag.get('v')
            break
            
    nd_refs = [nd.get('ref') for nd in best_way.findall('nd') if nd.get('ref') in selected_nodes]
    pts = [to_meters(*selected_nodes[ref]) for ref in nd_refs]
    
    # Normalize so first point is near (0, 0) and road runs along +x
    p0_x, p0_y = pts[0]
    p_last_x, p_last_y = pts[-1]
    angle = np.arctan2(p_last_y - p0_y, p_last_x - p0_x)
    
    rotated_pts = []
    for x_raw, y_raw in pts:
        dx = x_raw - p0_x
        dy = y_raw - p0_y
        rx = dx * np.cos(-angle) - dy * np.sin(-angle)
        ry = dx * np.sin(-angle) + dy * np.cos(-angle)
        rotated_pts.append((rx, ry))
    
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['point_idx', 'x_meters', 'y_meters', 'z_meters', 'road_name'])
        for idx, (rx, ry) in enumerate(rotated_pts):
            writer.writerow([idx, f"{rx:.2f}", f"{ry:.2f}", 0.0, way_name])
            
    print(f"Extracted primary real road corridor ({way_name}) with {len(rotated_pts)} waypoints into {output_csv}")
