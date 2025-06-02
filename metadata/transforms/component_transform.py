from helpers.metadata_helpers import generate_component_token_id, clean_row
import pandas as pd
import numpy as np

RESERVED_KEYS = {
    'tokenId','name', 'description', 'image', 'component_type', 'data_sheet'
}

def component_transform(df, asset_name, config):
    records = []

    for idx, row in df.iterrows():
        row = clean_row(row)
        record = {}

        manufacturer = row.get("manufacturer","")
        model = row.get("model","")
        component_type = asset_name
    
        token_id = generate_component_token_id(component_type, manufacturer, model)

        # Basic fields
        record['name'] = f"{manufacturer} {model}"
        record['description'] = row.get('description', "")
        record['image'] = f"ipfs://bayf.../{config['image_subdir']}"
        record['data_sheet'] = f"ipfs://bayf.../{config['doc_subdir']}"
        record['component_type'] = component_type
        record['tokenId'] = token_id

        record['attributes'] = []
        for key, value in row.items():
            if key not in RESERVED_KEYS and (value is not None) and (value is not np.nan):
                if pd.notna(value):
                    record['attributes'].append({"trait_type": key, "value": value})

        records.append(record)

    return pd.DataFrame(records)
