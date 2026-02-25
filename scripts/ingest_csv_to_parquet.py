"""
Télécharge les CSV Olist depuis Kaggle et les convertit en Parquet.
Prérequis : télécharger le zip depuis Kaggle et le décompresser dans data/raw/csv/
"""

import duckdb

con = duckdb.connect("data/olist.duckdb")

CSV_DIR = "data/raw/csv"
TABLES = {
    "raw_orders": "olist_orders_dataset.csv",
    "raw_order_items": "olist_order_items_dataset.csv",
    "raw_order_payments": "olist_order_payments_dataset.csv",
    "raw_order_reviews": "olist_order_reviews_dataset.csv",
    "raw_customers": "olist_customers_dataset.csv",
    "raw_products": "olist_products_dataset.csv",
    "raw_sellers": "olist_sellers_dataset.csv",
    "raw_geolocation": "olist_geolocation_dataset.csv",
}

for table_name, filename in TABLES.items():
    con.execute(f"""
        CREATE OR REPLACE TABLE {table_name} AS
        SELECT * FROM read_csv_auto('{CSV_DIR}/{filename}')
    """)
    count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
    print(f"✓ {table_name}: {count:,} rows")

con.close()
