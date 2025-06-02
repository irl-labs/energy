
"""
Database Connection Helper

This module provides utility functions for establishing connections to the PostgreSQL database
using SQLAlchemy. It retrieves connection parameters from environment variables managed by dotenv.

Environment Variables:
    POSTGRES_USER: Database username
    POSTGRES_PASSWORD: Database password
    POSTGRES_HOST: Database host (e.g., localhost or a container name)
    POSTGRES_PORT: Database port (e.g., 5432)
    POSTGRES_DB: Database name
"""

from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

def get_engine():
    """
    Create a SQLAlchemy engine using PostgreSQL credentials from environment variables.

    Returns:
        sqlalchemy.engine.Engine: SQLAlchemy engine object for database connection
    """
    db_url = (
        f"postgresql+psycopg2://{os.getenv('POSTGRES_USER')}:{os.getenv('POSTGRES_PASSWORD')}"
        f"@{os.getenv('POSTGRES_HOST')}:{os.getenv('POSTGRES_PORT')}/{os.getenv('POSTGRES_DB')}"
    )
    return create_engine(db_url)

def get_connection():
    """
    Establish a connection to the PostgreSQL database using the SQLAlchemy engine.

    Returns:
        sqlalchemy.engine.Connection: Active connection to the database
    """
    engine = get_engine()
    return engine.connect()

