# E-commerce Sales & Profitability Analytics

**Tools:** Python · PostgreSQL · SQL · Excel · Power BI

## 1. Business Problem

This project analyzes the Olist Brazilian E-Commerce dataset to investigate sales trends, freight costs, and delivery performance. The objective is to understand shipping-cost patterns that may reduce the amount retained from product sales and to develop data-driven business recommendations.

## 2. Dataset

The project uses the [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle — approximately 100,000 orders from 2016–2018 across nine CSV files.

## 3. Tools and Technologies

- **Python** — Data loading and preparation
- **PostgreSQL** — Data storage and querying
- **SQL** — Data-quality checks, joins, CTEs, window functions, business analysis
- **Excel** — Supplementary data analysis
- **Power BI** — Interactive KPI cards and analytical dashboards

## 4. Project Workflow

1. Download the raw CSV files from Kaggle.
2. Load the data into PostgreSQL using `load_data.py` (Python + pandas + SQLAlchemy).
3. Run data-quality checks for missing values, duplicates, and unmatched orders.
4. Run SQL queries to analyze revenue trends, freight costs, product categories, customer reviews, and shipping patterns.
5. Build a three-page Power BI report (sales overview, sales analysis, freight analysis).
6. Validate findings and prepare actionable business recommendations.

## 5. Repository Structure

```
├── load_data.py                    # Python CSV → PostgreSQL loader
├── requirements.txt                # Python dependencies
├── .gitignore
├── LICENSE
├── README.md
└── database/                       # SQL analysis scripts (run in order)
    ├── 00_database_setup_and_validation.sql
    ├── 01_order_analysis.sql
    ├── 02_product_analysis.sql
    ├── 03_payment_analysis.sql
    ├── 04_customer_delivery_analysis.sql
    ├── 05_profitability_analysis.sql
    ├── 06_data_quality_analysis.sql
    ├── 07_executive_summary.sql
    ├── 08_customer_analysis.sql
    ├── 09_seller_analysis.sql
    └── 10_geographic_analysis.sql
```

## 6. How to Run

### Prerequisites

- PostgreSQL 14+ installed and running locally
- Python 3.10+
- The nine Olist CSV files (download from Kaggle — not included in this repo due to size)

### Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/krati1107/sales-profitability-analytics.git
   cd sales-profitability-analytics
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Place the CSV files** in a `data/` folder at the repo root:
   ```
   data/olist_orders_dataset.csv
   data/olist_order_items_dataset.csv
   data/olist_order_payments_dataset.csv
   data/olist_order_reviews_dataset.csv
   data/olist_customers_dataset.csv
   data/olist_products_dataset.csv
   data/olist_sellers_dataset.csv
   data/olist_geolocation_dataset.csv
   data/product_category_name_translation.csv
   ```

4. **Set your PostgreSQL password** (PowerShell):
   ```powershell
   $env:POSTGRES_PASSWORD = "your_password"
   ```

5. **Run the loader** (auto-creates the `ecommerce` database):
   ```bash
   python load_data.py
   ```

6. **Run the SQL scripts** in pgAdmin or psql, in order `00` → `10`:
   ```bash
   psql -U postgres -d ecommerce -f database/00_database_setup_and_validation.sql
   psql -U postgres -d ecommerce -f database/01_order_analysis.sql
   # ... and so on through 10_geographic_analysis.sql
   ```

## 7. Key Business Questions

- How does revenue change month over month?
- What percentage of product price is spent on freight?
- Which states and product categories have higher freight burdens?
- How do same-state and cross-state shipments compare?
- Is late delivery associated with lower customer review scores?

## 8. Important Limitation

The dataset does **not** contain the actual cost of goods sold (COGS). Therefore, true profit and profit margin cannot be calculated. This project uses **product price minus freight value** as a freight-adjusted revenue proxy, not as actual profit.


## 8b. Dashboard Preview

### Page 1 — Executive Overview
![Executive Overview](dashboard/page1_executive_overview.png)

### Page 2 — Sales Analysis
![Sales Analysis](dashboard/page2_sales_analysis.png)

### Page 3 — Profitability & Freight Analysis
![Freight Analysis](dashboard/page3_freight_analysis.png)

*(The full interactive report is available in `dashboard/sales_profitability.pbix`)*

## 9. Project Status

- ✅ Data loading and PostgreSQL pipeline — complete
- ✅ SQL analysis scripts (11 files covering orders, products, payments, delivery, profitability, data quality, customers, sellers, geography) — complete
- 🚧 Power BI dashboard — in progress
- 🚧 Final insights and business recommendations — pending

## 10. License

MIT License — see [LICENSE](LICENSE).
