"""
load_data.py
Loads the 9 Olist CSV files into a MySQL database called `ecommerce`.

HOW TO RUN
1. pip install pandas sqlalchemy pymysql
2. Put the 9 CSV files inside the `data/` folder
3. Change DB_USER and DB_PASSWORD below
4. python load_data.py
"""

import os
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, types

# ---------- 1. SETTINGS (change these) ----------
DB_USER = "root"
DB_PASSWORD = "your_password"
DB_HOST = "localhost"
DB_PORT = 3306
DB_NAME = "ecommerce"
DATA_FOLDER = "data"

# CSV file name -> table name
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

# Columns that must be read as dates
DATE_COLUMNS = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
}


def build_dtypes(df):
    """Short text columns -> VARCHAR (fast joins). Long text -> TEXT."""
    dtypes = {}
    for col in df.columns:
        if df[col].dtype == "object":
            max_len = int(df[col].astype(str).str.len().max())
            if max_len <= 200:
                dtypes[col] = types.String(max_len + 20)
            else:
                dtypes[col] = types.Text()
    return dtypes


def main():
    pw = quote_plus(DB_PASSWORD)  # handles special characters like @ or #

    # Step A: create the database if it does not exist
    root_engine = create_engine(f"mysql+pymysql://{DB_USER}:{pw}@{DB_HOST}:{DB_PORT}/")
    with root_engine.begin() as conn:
        conn.exec_driver_sql(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")

    # Step B: connect to the new database
    engine = create_engine(
        f"mysql+pymysql://{DB_USER}:{pw}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"
    )

    # Step C: load each CSV
    for file_name, table in FILES.items():
        path = os.path.join(DATA_FOLDER, file_name)
        if not os.path.exists(path):
            print(f"[SKIPPED] {path} not found")
            continue

        df = pd.read_csv(path, parse_dates=DATE_COLUMNS.get(table, []))
        print(f"Loading {table:<22} rows = {len(df):>9,}")

        df.to_sql(
            table,
            engine,
            if_exists="replace",
            index=False,
            dtype=build_dtypes(df),
            chunksize=5000,
        )

    print("\nDone. Now run sql/01_setup_and_quality_checks.sql")


if __name__ == "__main__":
    main()
