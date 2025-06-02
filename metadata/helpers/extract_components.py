from numpy import nan
from pandas import notna

def extract_component_array(row, prefix, max_entries=3):
    """
    Extracts repeated _1, _2, _3 columns into an array of dicts.
    """
    fields = [
        "tokenId", "manufacturer", "model", "quantity",
        "technology", "BIPV", "bifacial", "nameplate_capacity",
        "efficiency","azimuth","tilt",
        "ground_mounted",
        "rated_capacity_kW", "rated_capacity_kWh",
        "price", "output_capacity"
    ]
    components = []
    for i in range(1, max_entries + 1):
        token_id = row.get(f"{prefix}_tokenId_{i}")
        if not token_id:
            continue  # Skip empty slots

        component = {}
        for field_suffix in fields:
            colname = f"{prefix}_{field_suffix}_{i}"
            val = row.get(colname)
            if notna(val):
                component[field_suffix] = val

        components.append(component)

    return components

