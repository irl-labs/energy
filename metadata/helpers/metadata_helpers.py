"""Metadata Helpers

This module provides utility functions for generating token IDs,
cleaning data rows, and testing metadata serialization for both
components and installations.

Functions:
    - generate_component_token_id: Generate a token ID for a component using keccak256 hashing.
    - generate_installation_token_id: Generate a Morton encoded token ID for an installation based on its centroid.
    - clean_row: Cleans data rows by handling NaN, datetime, and number conversions.
    - test_metadata_serialization: Validates JSON serialization of metadata.

"""

import json
from helpers.geometry_helpers import transform_centroid
from Crypto.Hash import keccak

def generate_component_token_id(component_type: str, manufacturer: str, model: str) -> str:
    """
    Generate a unique token ID for a component based on its type,
    manufacturer, and model.

    Args:
        component_type (str): The type of the component (e.g., "module", "inverter").
        manufacturer (str): The manufacturer name.
        model (str): The model name.

    Returns:
        str: A keccak256 hash converted to a uint256 as a string.

    """
    # Normalize and concatenate
    combined_string = f"{component_type.lower().replace(' ','')}|{manufacturer.lower().replace(' ','')}|{model.lower().replace(' ','')}"
    
    # Calculate the keccak256 hash
    keccak_hash = keccak.new(digest_bits=256)
    keccak_hash.update(combined_string.encode())
    hash_result = keccak_hash.hexdigest()
    
    # Convert the hexadecimal hash to a uint256
    uint256_hash = int(hash_result, 16)
    
    return str(uint256_hash)


def generate_installation_token_id(centroid) -> str:
    """
    Generate a Morton encoded token ID for an installation based on
    its centroid.

    Args:
        centroid (list): A list of [longitude, latitude].

    Returns:
        str: Morton encoded integer as a string.

    """
    centroid = transform_centroid(centroid)

    precision = 1e6
    lat_shift = 90
    lon_shift = 180
    ROUND = 6

    lon_int = int(round(precision * (centroid[0] + lon_shift), ROUND))
    lat_int = int(round(precision * (centroid[1] + lat_shift), ROUND))
    return str(encode_morton(lat_int, lon_int))


def interleave_bits(x, y):
    """
    Interleave the bits of two integers to form a Morton code.

    Args:
        x (int): The first integer (e.g., latitude).
        y (int): The second integer (e.g., longitude).

    Returns:
        int: Interleaved Morton code.
    """
    result = 0
    for i in range(32):
        result |= (x & (1 << i)) << i | (y & (1 << i)) << (i + 1)
    return result


def encode_morton(lat, lon):
    """
    Encode latitude and longitude into a single Morton code integer.

    Args:
        lat (int): Integer representation of latitude.
        lon (int): Integer representation of longitude.

    Returns:
        int: Morton encoded integer.
    """
    return interleave_bits(lat, lon)


def clean_row(row: dict) -> dict:
    """
    Cleans a data row by handling NaN, datetime, and numeric conversions.

    - Converts NaN, NaT, inf -> None
    - Converts pandas.Timestamp or datetime.datetime -> ISO8601 strings
    - Leaves lists, dicts, and other data structures untouched

    Args:
        row (dict): Data row to clean.

    Returns:
        dict: Cleaned data row.
    """
    from pandas import Timestamp, isna
    from datetime import datetime
    from numbers import Number

    cleaned = {}

    for k, v in row.items():
        # Handle datetime objects
        if isinstance(v, (Timestamp, datetime)):
            cleaned[k] = v.isoformat()
        # Handle numeric and string values
        elif isinstance(v, (Number, str)):
            if isna(v) or v in [float('inf'), float('-inf')]:
                cleaned[k] = None
            else:
                cleaned[k] = v
        else:
            cleaned[k] = v  # Pass lists, dicts, etc. unchanged

    return cleaned


def test_metadata_serialization(metadata: dict) -> bool:
    """
    Test JSON serialization of a metadata object.

    Args:
        metadata (dict): The metadata dictionary to test.

    Returns:
        bool: True if serialization is successful, False otherwise.
    """
    try:
        _ = json.dumps(metadata)
        return True
    except (TypeError, ValueError) as e:
        print(f"❌ JSON serialization failed: {e}")
        return False
