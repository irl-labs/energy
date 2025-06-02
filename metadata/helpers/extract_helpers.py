import pandas as pd
import requests
from io import BytesIO

CA_SOLAR_BASE_URL = 'https://solarequipment.energy.ca.gov/Home/DownloadtoExcel'

def extract_excel(source_location: str, skiprows: int) -> pd.DataFrame:
    url = CA_SOLAR_BASE_URL + '?filename=' + source_location
    df = pd.read_excel(url, skiprows=skiprows)
    df = df.drop(0, axis=0).reset_index(drop=True)
    return df

def extract_csv(url: str) -> pd.DataFrame:
    return pd.read_csv(url)

def extract_api(url: str) -> pd.DataFrame:
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()
    return pd.json_normalize(data)

def extract_manual(filepath: str) -> pd.DataFrame:
    return pd.read_csv(filepath)
