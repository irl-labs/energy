import json
from pathlib import Path
from jsonschema import validate, ValidationError, SchemaError

def load_schema(asset_type: str) -> dict:
    """
    Load the appropriate JSON schema for components or installations.
    """
    schema_path = Path(f"./schemas/{asset_type}_schema.json")
    if not schema_path.exists():
        raise FileNotFoundError(f"Schema file not found: {schema_path}")

    with open(schema_path, "r") as f:
        return json.load(f)

def validate_metadata(metadata: dict, schema: dict, token_id: int) -> bool:
    """
    Validate metadata against its schema.
    """
    try:
        validate(instance=metadata, schema=schema)
        return True
    except ValidationError as e:
        print(f"❌ Validation error for tokenId {token_id}: {e.message}")
        return False
    except SchemaError as e:
        print(f"❌ Schema error: {e.message}")
        return False
    