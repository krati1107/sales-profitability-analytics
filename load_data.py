"""
load_data.py
Loads the 9 Olist CSV files into the MySQL ecommerce database.

Install:
    pip install pandas sqlalchemy pymysql

Before running:
    1. Put all 9 CSV files inside the data/ folder.
    2. Set DB_PASSWORD in your environment.
    3. Set DB_USER if you do not use the default root account.
    4. Run: python load_data.py
"""

import os
import re
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, types
from sqlalchemy.engine import URL


# ---------- 1. SETTINGS ----------
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD")

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_NAME = "ecommerce"
DATA_FOLDER = Path("data")


# CSV filename -> MySQL table name
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
    """Choose VARCHAR for short text columns and TEXT for longer ones."""
    dtypes = {}

    for col in df.columns:
        if df[col].dtype == "object":
            values = df[col].dropna().astype(str)

            max_len = (
                int(values.str.len().max())
                if not values.empty
                else 1
            )

            if max_len <= 200:
                dtypes[col] = types.String(max_len + 20)
            else:
                dtypes[col] = types.Text()

    return dtypes


def validate_files():
    """Fail before loading if any required CSV is missing."""
    missing = [
        str(DATA_FOLDER / filename)
        for filename in FILES
        if not (DATA_FOLDER / filename).is_file()
    ]

    if missing:
        raise FileNotFoundError(
            "Missing required CSV files:\n"
            + "\n".join(missing)
        )


def main():
    # Validate configuration before starting.
    if not DB_PASSWORD:
        raise ValueError(
            "Set the DB_PASSWORD environment variable first."
        )

    if not re.fullmatch(r"[A-Za-z0-9_]+", DB_NAME):
        raise ValueError("Invalid database name.")

    validate_files()

    # URL.create safely handles special characters in passwords.
    server_url = URL.create(
        "mysql+pymysql",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
    )

    root_engine = create_engine(server_url)
    engine = None

    try:
        # Create the database if it does not exist.
        with root_engine.begin() as conn:
            conn.exec_driver_sql(
                f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}`"
            )

        # Connect to the ecommerce database.
        database_url = server_url.set(
            database=DB_NAME,
            query={"charset": "utf8mb4"},
        )
        engine = create_engine(database_url)

        # Load each CSV into its matching table.
        for filename, table in FILES.items():
            path = DATA_FOLDER / filename

            df = pd.read_csv(
                path,
                parse_dates=DATE_COLUMNS.get(table, []),
            )

            print(f"Loading {table:<22} rows = {len(df):>9,}")

            df.to_sql(
                table,
                engine,
                if_exists="fail",
                index=False,
                dtype=build_dtypes(df),
                chunksize=5000,
            )

        print("\nAll CSV files loaded successfully.")
        print("Next: run 01_setup_and_quality_checks.sql")

    finally:
        if engine is not None:
            engine.dispose()

        root_engine.dispose()


if __name__ == "__main__":
    main()

