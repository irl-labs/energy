
#!/usr/bin/env python
# coding: utf-8

"""Unified Metadata Generation Script

This script generates metadata for both components and installations
based on the specified registry configuration. It extracts,
transforms, and validates data, then stores the generated metadata
JSON files in the IPFS directory structure and inserts the metadata
into the PostgreSQL database.

Usage:
    python cli/generate_metadata.py --type <component|installation> --name <registry_key>

Example:
    python cli/generate_metadata.py --type component --name solar_module

"""

import argparse
import json
from pathlib import Path
import pandas as pd

from helpers.db import get_connection
from helpers.registry_loader import flatten_registry
from helpers.metadata_helpers import (
    generate_installation_token_id,
    clean_row,
    test_metadata_serialization
)
from helpers.schema_loader import load_schema, validate_metadata
from services.postgres_helpers import (
    insert_component_metadata,
    insert_installation_metadata
)
from helpers.extract_helpers import (
    extract_excel, extract_csv, extract_api, extract_manual
)
from transforms.component_transform import component_transform


def generate_metadata(asset_type: str, asset_name: str):
    """
    Generate metadata for components or installations.

    Args:
        asset_type (str): Type of asset ("component" or "installation").
        asset_name (str): Registry key for the asset type.

    Raises:
        ValueError: If the asset_name is not found in the registry.
    """
    # Load registry
    registry = flatten_registry(asset_type)
    if asset_name not in registry:
        raise ValueError(f"{asset_type.title()} '{asset_name}' not found in registry.")

    config = registry[asset_name]

    # Extract data using the specified function
    extract_fn = globals()[config['extract_function']]
    if asset_type == "component":
        df = extract_fn(config['source_location'], config.get('skiprows', 0))
    else:
        df = extract_fn(config['source_location'])
    df = df.where(pd.notnull(df), None)

    # Transform data
    transform_fn_module = __import__(f"transforms.{config['transform_function'].replace('_transform','')}_transform", fromlist=[config['transform_function']])
    transform_fn = getattr(transform_fn_module, config['transform_function'])
    df = transform_fn(df)
    
    # Apply additional component-specific transformations
    if asset_type == "component":
        df = component_transform(df, asset_name, config)

    # Prepare output directory
    output_dir = Path(f"./ipfs/{asset_type}s/{asset_name}/")
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load database connection and schema
    conn = get_connection()
    schema = load_schema(asset_type)

    success, failed = 0, 0

    # Process each row and generate metadata
    for _, row in df.iterrows():
        metadata = clean_row(row)

        # Generate tokenId
        token_id = generate_installation_token_id(metadata["centroid"]) if asset_type == "installation" else metadata["tokenId"]
        metadata["tokenId"] = token_id
        metadata[f"{asset_type}_type"] = asset_name

        # Validate metadata against schema
        if not validate_metadata(metadata, schema, token_id):
            failed += 1
            continue

        # Test JSON serialization
        if not test_metadata_serialization(metadata):
            failed += 1
            continue

        # Compactify geometry coordinates for readability
        if "geometry" in metadata and "coordinates" in metadata["geometry"]:
            coordinates = metadata["geometry"]["coordinates"]
            compact_coords = json.dumps(coordinates, separators=(',', ':'))
            metadata["geometry"]["coordinates"] = compact_coords

        # Save metadata as JSON file
        output_path = output_dir / f"{token_id}.json"
        with open(output_path, "w") as f:
            json.dump(metadata, f, indent=2)

        # Insert into PostgreSQL
        if asset_type == "installation":
            insert_installation_metadata(metadata, conn)
        else:
            insert_component_metadata(metadata, conn)

        success += 1

    print(f"✅ {success} {asset_type}s processed, {failed} failures.")


def main():
    """
    Main function for CLI argument parsing and metadata generation.
    """
    parser = argparse.ArgumentParser(description="Unified metadata generator for components and installations.")
    parser.add_argument("--type", required=True, choices=["component", "installation"], help="Type of asset to generate metadata for.")
    parser.add_argument("--name", required=True, help="Registry key for the asset type (e.g., solar_array, battery_bank).")

    args = parser.parse_args()
    generate_metadata(args.type, args.name)


if __name__ == "__main__":
    main()
