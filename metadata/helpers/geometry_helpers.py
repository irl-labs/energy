import json
from shapely import wkt

def decode_geometry_geojson(geojson_str):
    """
    Just loads the GeoJSON as a Python dict.
    """
    return json.loads(geojson_str)

def transform_centroid(centroid):
    """
    Transform a POINT string into a [lat, lon] list.
    """
    if isinstance(centroid, str) and centroid.strip().upper().startswith('POINT'):
        pt = wkt.loads(centroid)
        return [round(pt.x,7), round(pt.y,7)]  # (lat, lon) order
    elif isinstance(centroid, (list, tuple)):
        return list(centroid)  # Already good
    else:
        raise ValueError(f"Unsupported centroid format: {centroid}")
