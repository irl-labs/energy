
# Energy Metadata Accounting

This project provides a comprehensive framework for generating, storing, and verifying metadata 
for energy-related assets, including solar components and installations. It supports data extraction, 
metadata transformation, IPFS storage, and PostgreSQL integration.

## 📂 Directory Structure

```
/metadata_accounting/
├── cli/
│   ├── generate_metadata.py      # CLI for generating metadata
│   └── upload_ipfs.py            # CLI for IPFS uploads
├── helpers/
│   ├── db.py                     # Database connection helper
│   ├── metadata_helpers.py       # Metadata processing helpers
│   ├── postgres_helpers.py       # PostgreSQL interaction functions
│   └── schema_loader.py          # JSON schema loading and validation
├── services/
│   └── ipfs_upload.py            # IPFS upload service
├── transforms/
│   ├── components_transform.py   # Transformations for components
│   └── installations_transform.py # Transformations for installations
├── schemas/
│   ├── component_schema.json     # JSON schema for components
│   └── installation_schema.json  # JSON schema for installations
├── data/
│   └── solar_array_registry.csv  # Sample installation data
├── .env                          # Environment variables
├── Makefile                      # Makefile with project tasks
├── requirements.txt              # Python dependencies
└── README.md                     # Project documentation
```

## ✅ Installation and Setup

1. **Clone the repository:**

```bash
git clone https://github.com/irl-labs/energy/metadata.git
cd metadata
```

2. **Create a virtual environment and install dependencies:**

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. **Set up the environment variables:**

Create a `.env` file in the project root with the following content:

```
POSTGRES_USER=<your_username>
POSTGRES_PASSWORD=<your_password>
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=energy
IPFS_HOST=http://127.0.0.1
IPFS_PORT=5001
```

## 🚀 Usage

### Generate Metadata for Components:

```bash
make generate-components
```

### Generate Metadata for Installations:

```bash
make generate-installations
```

### Insert Metadata into PostgreSQL:

```bash
make insert-db
```

### Upload Metadata to IPFS:

```bash
make upload-ipfs
```

### Read Metadata from PostgreSQL:

```bash
make read-db
```

### Clean Temporary Files and IPFS Data:

```bash
make clean
```

### Reset the Project:

```bash
make reset
```

## ⚙️ Example Commands

- Generate metadata for solar modules:

  ```bash
  python cli/generate_metadata.py --type component --name solar_module
  ```

- Upload all metadata to IPFS:

  ```bash
  python cli/upload_ipfs.py --dir ./ipfs/components/
  ```

## 🛠️ Contributing

1. Fork the repository and create a new branch for your feature/bugfix.
2. Ensure code is properly formatted and follows project structure.
3. Submit a pull request with detailed information on changes.

## 📄 License

This project is licensed under the MIT License. See `LICENSE.md` for details.

---

For further information, contact the project maintainer at [irl-labs@proton.me].