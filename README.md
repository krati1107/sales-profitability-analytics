E-commerce Sales & Profitability Analytics

Tools: MySQL · SQL (CTEs, joins, window functions) · Python (data loading) · Excel · Power BI

1. Business Problem

An online marketplace saw sales volume rise but profit margins fall. This project finds out why, and recommends actions.

2. Dataset

Olist Brazilian E-Commerce Public Dataset (Kaggle): 9 CSV files (orders, order items, payments, reviews, customers, products, sellers, geolocation, category translation). About 100,000 orders from 2016–2018.

The CSV files are not uploaded here because of size. Download them from Kaggle and place them in the data/ folder.

3. Important Assumption

The dataset has no cost-of-goods data, so true profit cannot be calculated. I used a margin proxy:

net_after_freight = price − freight_value
freight % = freight_value ÷ price × 100
4. Project Structure
sales-profitability-analytics/
├── data/                          (put the 9 Kaggle CSVs here)
├── sql/
│   ├── 01_setup_and_quality_checks.sql
│   └── 02_analysis_queries.sql    (26 queries)
├── dashboard/
│   ├── powerbi_guide.md
│   ├── sales_profitability.pbix   (your file)
│   └── page1.png, page2.png, page3.png
├── load_data.py
└── README.md
5. How to Run
Install MySQL 8+ and Python 3.9+
pip install pandas sqlalchemy pymysql
Download the dataset and put the CSVs in data/
Edit DB_USER and DB_PASSWORD in load_data.py, then run python load_data.py
Run sql/01_setup_and_quality_checks.sql (indexes, checks, and the vw_sales view)
Run sql/02_analysis_queries.sql query by query
Build the dashboard using dashboard/powerbi_guide.md
6. Method
Data quality checks: row counts, NULLs, duplicates, date range, orders without items
Cleaning view: only delivered orders, English category names, region mapping, late-delivery flag
KPIs: revenue, orders, AOV, CLV, MoM growth
Root cause analysis: freight % by state, region, category, weight, and same-state vs cross-state shipping
Dashboard: 3-page Power BI report
7. Key Findings ← FILL THESE WITH YOUR OWN RESULTS

Run the queries first, then replace every [ ] below with real numbers.

#	Finding	Evidence (query)	Recommendation
1	Revenue grew [ ]% from [month] to [month]	Q2, Q3	—
2	Freight was [ ]% of revenue overall, and moved from [ ]% to [ ]%	Q1, Q2	—
3	[Region] had the highest freight at [ ]% of product price	Q6, Q7	Renegotiate freight rates or onboard local sellers
4	Cross-state orders cost [ ]% more freight than same-state orders	Q13	Recruit sellers in high-freight regions
5	Late orders had an average review of [ ] vs [ ] for on-time orders	Q25	Improve delivery promise accuracy
8. Limitations
No cost data, so margin is a proxy (see section 3)
Early 2016 and late 2018 months have very few orders, so trends use 2017-01 to 2018-08
Most customers buy only once, so CLV here is historical spend and not a prediction
