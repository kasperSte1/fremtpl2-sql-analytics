"""Loads data/raw/*.csv into the raw schema with COPY."""

from pathlib import Path
import pandas as pd
from db import CONN
import psycopg

ROOT = Path(__file__).parent.parent
RAW = ROOT / 'data' / 'raw'

freq_path = RAW / 'freq.csv'
sev_path = RAW / 'sev.csv'

freq = pd.read_csv(freq_path)
sev = pd.read_csv(sev_path)

freq = freq.rename(columns={
    "IDpol": "id_pol",
    "ClaimNb": "claim_nb",
    "Exposure": "exposure",
    "Area": "area",
    "VehPower": "veh_power",
    "VehAge": "veh_age",
    "DrivAge": "driv_age",
    "BonusMalus": "bonus_malus",
    "VehBrand": "veh_brand",
    "VehGas": "veh_gas",
    "Density": "density",
    "Region": "region",
})
assert (freq["id_pol"] % 1 == 0).all(), "id_pol has fractional values"
freq["id_pol"] = freq["id_pol"].astype("int32")

sev = sev.rename(columns={
    "IDpol": "id_pol",
    "ClaimAmount": "claim_amount",
})

assert (sev["id_pol"] % 1 == 0).all(), "id_pol has fractional values"
sev["id_pol"] = sev["id_pol"].astype("int32")

# swapping columns for clarity
freq = freq[["id_pol", "claim_nb", "exposure", "veh_power", "veh_age", "driv_age", "bonus_malus", "veh_brand",
             "veh_gas", "area", "density", "region"]]

with psycopg.connect(CONN) as conn:
    with conn.cursor() as cur:
        cur.execute("TRUNCATE raw.freq, raw.sev;")

        with cur.copy("COPY raw.freq (id_pol, claim_nb, exposure, veh_power, veh_age, driv_age,"
                        " bonus_malus, veh_brand, veh_gas, area, density, region) FROM STDIN") as cp:
            for row in freq.itertuples(index=False, name=None):
                cp.write_row(row)
        with cur.copy("COPY raw.sev (id_pol, claim_amount) FROM STDIN") as cp:
            for row in sev.itertuples(index=False, name=None):
                cp.write_row(row)
        cur.execute("SELECT COUNT(*) FROM raw.freq;")
        print("freq:", cur.fetchone()[0])
        cur.execute("SELECT COUNT(*) FROM raw.sev;")
        print("sev:", cur.fetchone()[0])