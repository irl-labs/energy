
"""PostgreSQL Helpers for Metadata Storage

This module provides utility functions for inserting and reading
component and installation metadata in PostgreSQL. The functions
handle data transformations, conflict handling, and spatial data
encoding using GeoAlchemy2.

Functions:
    - insert_installation_metadata: Insert or update installation metadata in the 'installations' table.
    - insert_component_metadata: Insert or update component metadata in the 'components' table.
    - read_installation_metadata: Retrieve installation metadata by token ID.
    - read_component_metadata: Retrieve component metadata by token ID.

"""

import json
import datetime
from sqlalchemy import MetaData, Table, text
from sqlalchemy.dialects.postgresql import insert
from shapely.geometry import shape, Point
from geoalchemy2.shape import from_shape

def insert_installation_metadata(metadata: dict, conn):
    """
    Insert or update installation metadata in the PostgreSQL database.

    Args:
        metadata (dict): Metadata dictionary for the installation.
        conn (sqlalchemy.engine.Connection): Active database connection.

    Raises:
        Exception: If database insertion fails.
    """
    token_id = int(metadata['tokenId'])
    name = metadata.get('name', f"Installation {token_id}")
    installation_type = metadata.get('installation_type', 'unknown')

    # Extract centroid and geometry
    centroid_coords = metadata['centroid']
    geometry_coords = json.loads(metadata['geometry']['coordinates']) if isinstance(metadata['geometry']['coordinates'], str) else metadata['geometry']['coordinates']

    # Convert to spatial objects
    centroid = from_shape(Point(centroid_coords[1], centroid_coords[0]), srid=4326)
    multipolygon = from_shape(shape({
        "type": "MultiPolygon",
        "coordinates": geometry_coords
    }), srid=4326)

    # Metadata Table
    metadata_obj = MetaData()
    installations = Table("installations", metadata_obj, autoload_with=conn, schema="accounting")

    # Insert or Update
    insert_stmt = insert(installations).values(
        token_id=token_id,
        name=name,
        installation_type=installation_type,
        centroid=centroid,
        geometry=multipolygon,
        metadata=metadata,
        created_at=datetime.datetime.utcnow()
    ).on_conflict_do_update(
        index_elements=['token_id'],
        set_={
            "name": name,
            "installation_type": installation_type,
            "centroid": centroid,
            "geometry": multipolygon,
            "metadata": metadata,
            "created_at": datetime.datetime.utcnow()
        }
    )

    conn.execute(insert_stmt)
    conn.commit()


def insert_component_metadata(metadata: dict, conn):
    """
    Insert or update component metadata in the PostgreSQL database.

    Args:
        metadata (dict): Metadata dictionary for the component.
        conn (sqlalchemy.engine.Connection): Active database connection.

    Raises:
        Exception: If database insertion fails.
    """
    token_id = int(metadata['tokenId'])
    name = metadata.get('name', f"Component {token_id}")
    component_type = metadata.get('component_type', 'unknown')

    # Metadata Table
    metadata_obj = MetaData()
    components = Table("components", metadata_obj, autoload_with=conn, schema="accounting")

    # Insert or Update
    insert_stmt = insert(components).values(
        token_id=token_id,
        name=name,
        component_type=component_type,
        metadata=metadata,
        created_at=datetime.datetime.utcnow()
    ).on_conflict_do_update(
        index_elements=['token_id'],
        set_={
            "name": name,
            "component_type": component_type,
            "metadata": metadata,
            "created_at": datetime.datetime.utcnow()
        }
    )

    conn.execute(insert_stmt)
    conn.commit()


def read_installation_metadata(token_id: int, conn) -> dict:
    """
    Retrieve installation metadata by token ID.

    Args:
        token_id (int): Unique identifier for the installation.
        conn (sqlalchemy.engine.Connection): Active database connection.

    Returns:
        dict: Metadata for the installation, or None if not found.
    """
    sql = text("SELECT metadata FROM accounting.installations WHERE token_id = :token_id")
    result = conn.execute(sql, {"token_id": token_id}).fetchone()
    return result[0] if result else None


def read_component_metadata(token_id: int, conn) -> dict:
    """
    Retrieve component metadata by token ID.

    Args:
        token_id (int): Unique identifier for the component.
        conn (sqlalchemy.engine.Connection): Active database connection.

    Returns:
        dict: Metadata for the component, or None if not found.
    """
    sql = text("SELECT metadata FROM accounting.components WHERE token_id = :token_id")
    result = conn.execute(sql, {"token_id": token_id}).fetchone()
    return result[0] if result else None
