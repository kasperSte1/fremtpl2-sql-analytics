"""Connection string assembled from .env. Run directly to test the connection."""

import os
from pathlib import Path
from dotenv import load_dotenv
import psycopg

ROOT = Path(__file__).parent.parent
load_dotenv(ROOT / ".env")

CONN = (
    f"host={os.environ['POSTGRES_HOST']} "
    f"port={os.environ['POSTGRES_PORT']} "
    f"dbname={os.environ['POSTGRES_DB']} "
    f"user={os.environ['POSTGRES_USER']} "
    f"password={os.environ['POSTGRES_PASSWORD']}"
)

if __name__ == "__main__":
    with psycopg.connect(CONN) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT version();")
            print(cur.fetchone()[0])