# E-commerce Sales & Profitability Analytics

**Tools:** MySQL · SQL (CTEs, joins, window functions) · Python (data loading) · Excel · Power BI

---

## 1. Business Problem

An online marketplace saw sales volume rise but profit margins fall. This project investigates why, and recommends actions.

---

## 2. Dataset

**Olist Brazilian E-Commerce Public Dataset** (Kaggle): 9 CSV files (orders, order items, payments, reviews, customers, products, sellers, geolocation, category translation). ~100,000 orders from 2016–2018.

CSVs are not uploaded here due to size. Download from Kaggle and place them in `data/`.

🔗 https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## 3. Important Assumption

The dataset has no cost-of-goods data, so true profit cannot be calculated. I use a **margin proxy**:

- `net_after_freight = price − freight_value`
- `freight % = freight_value ÷ price × 100`

---

## 4. Project Structure
sales-profitability-analytics/
├── data/ # Place the 9 Kaggle CSVs here
├── sql/
│ ├── 01_setup_and_quality_checks.sql # Indexes, checks, vw_sales view
│ └── 02_analysis_queries.sql # 26 analysis queries
├── dashboard/
│ ├── powerbi_guide.md
│ └── page1.png, page2.png, page3.png # Power BI screenshots (in progress)
├── load_data.py # Loads CSVs into MySQL
├── LICENSE
└── README.md

---

## 5. How to Run

1. Install MySQL 8+ and Python 3.9+
2. `pip install pandas sqlalchemy pymysql`
3. Download the dataset and put the CSVs in `data/`
4. Edit `DB_USER` and `DB_PASSWORD` in `load_data.py`, then run:
   ```bash
   python load_data.py

6. Method
Data quality checks: row counts, NULLs, duplicates, date range, orders without items

Cleaning view: only delivered orders, English category names, region mapping, late-delivery flag

KPIs: revenue, orders, AOV, CLV, MoM growth

Root-cause analysis: freight % by state, region, category, weight, and same-state vs cross-state shipping

Dashboard: 3-page Power BI report

7. Analysis Questions
All findings are reproducible by running sql/02_analysis_queries.sql. Key questions the analysis answers:

#	Question	Query
1	How has revenue changed month over month across 2017–2018?	Q1, Q2
2	What share of product price goes to freight, and how has that moved?	Q3, Q4
3	Which states carry the highest freight burden relative to product price?	Q6, Q7
4	How much more do cross-state orders cost in freight than same-state?	Q13
5	How does late delivery affect customer review scores?	Q25
Run the queries above against the Olist dataset to reproduce the findings. Insights and the Power BI dashboard will be added after final review.

8. Limitations
No cost-of-goods data, so margin is a proxy (see Section 3)

Early 2016 and late 2018 months have very few orders — trends use 2017-01 to 2018-08

Most customers buy only once, so CLV here is historical spend, not a prediction

9. License
MIT — see LICENSE.

   


   






 


 



