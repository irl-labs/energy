import yaml

def load_registry(asset_type):
    with open(f"config/{asset_type}_registry.yaml", "r") as f:
        return yaml.safe_load(f)

def flatten_registry(asset_type):
    full_registry = load_registry(asset_type)
    flat_registry = {}
    for metadata_type, token_type in full_registry.items():
        for token_name, config in token_type.items():
            flat_registry[token_name] = config
    return flat_registry
