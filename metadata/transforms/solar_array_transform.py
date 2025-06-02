from helpers.geometry_helpers import decode_geometry_geojson, transform_centroid
from helpers.extract_components import extract_component_array
from helpers.metadata_helpers import generate_installation_token_id
import pandas as pd
import numpy as np


RESERVED_KEYS = {
    'tokenId', 'centroid', 'geometry',
    'modules', 'inverters', 'batteries', 'lines', 'meters', 'transformers',
    'name', 'description', 'image', 'installation_type'
}

def solar_array_transform(df):
    df = df.drop("geometry",axis=1).rename(columns={"wkt_geometry":"geometry"})
    records = []

    for idx, row in df.iterrows():
        record = {}

        # Handle centroid
        centroid = transform_centroid(row['centroid'])

        # Morton encode tokenId
        record['tokenId'] = generate_installation_token_id(centroid)

        # Basic fields
        record['name'] = row.get('name', f"Installation {record['tokenId']}")
        record['description'] = row.get('description', "")
        record['image'] = row.get('image', "")
        record['installation_type'] = "generation"

        record['centroid'] = centroid
        #record['bbox'] = row.get('bbox', "")
        # Geometry (already extracted via ST_AsGeoJSON)
        record['geometry'] = decode_geometry_geojson(row['geometry'])

        # Components
        record['components'] = {
            "modules": extract_component_array(row, "module"),
            "inverters": extract_component_array(row, "inverter"),
            "batteries": extract_component_array(row, "battery")
        }

        record['attributes'] = []
        for key, value in row.items():
            if key not in RESERVED_KEYS and (value is not None) and (value is not np.nan) and ("module_" not in key) and ("inverter_" not in key) and ("battery_" not in key):
                if pd.notna(value):
                    record['attributes'].append({"trait_type": key, "value": value})


        records.append(record)

    return pd.DataFrame(records)
