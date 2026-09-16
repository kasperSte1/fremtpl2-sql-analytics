"""Fetches freMTPL2freq and freMTPL2sev from OpenML into data/raw/."""

from pathlib import Path
from sklearn.datasets import fetch_openml

ROOT = Path(__file__).parent.parent
RAW = ROOT / "data" / "raw"
RAW.mkdir(parents=True, exist_ok=True)

freq = fetch_openml(data_id=41214, as_frame=True).frame
sev = fetch_openml(data_id=41215, as_frame=True).frame

freq.to_csv(RAW / "freq.csv", index=False)
sev.to_csv(RAW / "sev.csv", index=False)

print(f"Saved {freq.shape[0]} policies and {sev.shape[0]} claims to data/raw/")