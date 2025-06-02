import subprocess
from pathlib import Path

def upload_directory_to_ipfs(directory_path: str) -> str:
    """
    Upload a directory to IPFS using the IPFS CLI *inside* the Docker container.
    Assumes the container is named 'ipfs_host'.
    """
    path = Path(directory_path)
    if not path.exists():
        raise FileNotFoundError(f"❌ Directory {directory_path} not found.")

    try:
        # Use docker exec to run inside the container
        result = subprocess.run(
            ["docker", "exec", "ipfs_host", "ipfs", "add", "-Qr", "/data/ipfs"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
            text=True
        )
        cid = result.stdout.strip()
        print(f"📦 Uploaded {directory_path} with CID: {cid}")
        return cid

    except subprocess.CalledProcessError as e:
        print(f"❌ Docker IPFS upload failed:\n{e.stderr}")
        raise

if __name__ == "__main__":
    components_path = "./ipfs/components"
    installations_path = "./ipfs/installations"

    print("📤 Uploading components directory...")
    components_cid = upload_directory_to_ipfs(components_path)

    print("📤 Uploading installations directory...")
    installations_cid = upload_directory_to_ipfs(installations_path)

    print("\n✅ Uploads complete:")
    print(f"🔗 Components baseURI: ipfs://{components_cid}/{{id}}.json")
    print(f"🔗 Installations baseURI: ipfs://{installations_cid}/{{id}}.json")

