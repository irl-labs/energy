
# Makefile for Energy Metadata Project

# Load environment variables
include .env

# Define variables
PYTHON = python3
PYTHONPATH := $(shell pwd)
IPFS_DIR := ipfs
COMPONENT_DIR := $(IPFS_DIR)/components
INSTALLATION_DIR := $(IPFS_DIR)/installations
SCHEMA_DIR := schemas
HELPERS_DIR := helpers
CLI_DIR := cli

export PYTHONPATH

# Default target
.PHONY: all
all: setup env

# Setup virtual environment
.PHONY: env
env:
	$(PYTHON) -m venv venv
	. venv/bin/activate
	pip install -r requirements.txt

# Run metadata generation for components
.PHONY: generate-components
generate-components:
	@echo "Generating component metadata..."
	$(PYTHON) $(CLI_DIR)/generate_metadata.py --type component --name meter

# Run metadata generation for installations
.PHONY: generate-installations
generate-installations:
	@echo "Generating installation metadata..."
	$(PYTHON) $(CLI_DIR)/generate_metadata.py --type installation --name solar_array

# Upload to IPFS
.PHONY: upload-ipfs
upload-ipfs:
	@echo "Uploading components and installations to IPFS..."
	$(PYTHON) $(CLI_DIR)/upload_ipfs.py --dir $(COMPONENT_DIR)
	$(PYTHON) $(CLI_DIR)/upload_ipfs.py --dir $(INSTALLATION_DIR)

# Insert metadata into PostgreSQL
.PHONY: insert-db
insert-db:
	@echo "Inserting metadata to PostgreSQL..."
	$(PYTHON) $(CLI_DIR)/generate_metadata.py --type component --name meter
	$(PYTHON) $(CLI_DIR)/generate_metadata.py --type installation --name solar_array

# Read metadata from PostgreSQL
.PHONY: read-db
read-db:
	@echo "Reading metadata from PostgreSQL..."
	$(PYTHON) -c "from helpers.postgres_helpers import read_installation_metadata, read_component_metadata; print(read_installation_metadata(12345, get_connection()))"

# Clean IPFS and temporary files
.PHONY: clean
clean:
	@echo "Cleaning up IPFS and temporary files..."
	rm -rf $(COMPONENT_DIR)/*
	rm -rf $(INSTALLATION_DIR)/*
	find . -name "*.pyc" -exec rm -f {} \;

# Full reset
.PHONY: reset
reset: clean env
	@echo "Project has been reset."
