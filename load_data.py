from pathlib import Path
from urllib.parse import quote_plus
import os

import pandas as pd
from sqlalchemy import create_engine, types, text

# ---------- DATABASE SETTINGS ----------
DB_USER = "postgres"
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "")
DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "ecommerce"

# ---------- CSV FOLDER ----------
BASE_DIR = Path(__file__).resolve().parent
DATA_FOLDER = BASE_DIR / "data"

FILES = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "category_translation",
}

DATE_COLUMNS = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
    "order_reviews": [
        "review_creation_date",
        "review_answer_timestamp",
    ],
}


def build_dtypes(df):
    """Choose suitable text types for PostgreSQL columns."""
    dtypes = {}

    for col in df.columns:
        if df[col].dtype == "object":
            lengths = df[col].dropna().astype(str).str.len()
            max_len = int(lengths.max()) if not lengths.empty else 1

            if max_len <= 200:
                dtypes[col] = types.String(max_len + 20)
            else:
                dtypes[col] = types.Text()

    return dtypes


def ensure_database(password):
    """Create the target database if it does not exist."""
    admin_url = (
        f"postgresql+psycopg://{DB_USER}:{password}"
        f"@{DB_HOST}:{DB_PORT}/postgres"
    )
    admin_engine = create_engine(admin_url, isolation_level="AUTOCOMMIT")

    try:
        with admin_engine.connect() as conn:
            exists = conn.execute(
                text("SELECT 1 FROM pg_database WHERE datname = :name"),
                {"name": DB_NAME},
            ).scalar()

            if exists:
                print(f"Database '{DB_NAME}' already exists.")
            else:
                conn.execute(text(f'CREATE DATABASE "{DB_NAME}"'))
                print(f"Created database '{DB_NAME}'.")
    finally:
        admin_engine.dispose()


def main():
    print("Starting Olist CSV import...")

    if not DB_PASSWORD:
        print("ERROR: PostgreSQL password is not configured.")
        print(
            'In PowerShell, run: $env:POSTGRES_PASSWORD = "your password"'
        )
        return

    missing = [
        filename for filename in FILES
        if not (DATA_FOLDER / filename).is_file()
    ]

    if missing:
        print("ERROR: CSV files not found:")
        for filename in missing:
            print(f" - {filename}")
        print(f"Expected folder: {DATA_FOLDER}")
        return

    password = quote_plus(DB_PASSWORD)

    ensure_database(password)

    database_url = (
        f"postgresql+psycopg://{DB_USER}:{password}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    engine = None

    try:
        engine = create_engine(database_url)

        with engine.connect() as conn:
            print("Connected to PostgreSQL database:", DB_NAME)

        for filename, table in FILES.items():
            path = DATA_FOLDER / filename
            date_cols = DATE_COLUMNS.get(table, [])

            print(f"\nReading {filename}...")
            df = pd.read_csv(path, parse_dates=date_cols)
            print(f"Loading '{table}': {len(df):,} rows")

            # WARNING: replace overwrites an existing table.
            df.to_sql(
                table,
                engine,
                if_exists="replace",
                index=False,
                dtype=build_dtypes(df),
                chunksize=5000,
            )

            print(f"SUCCESS: {table}")

        print("\nImport finished. All nine CSV files were processed.")
        print("Next: verify tables and row counts in pgAdmin.")

    except Exception as exc:
        print(f"\nIMPORT FAILED: {type(exc).__name__}: {exc}")
        raise

    finally:
        if engine is not None:
            engine.dispose()


if __name__ == "__main__":
    main()
