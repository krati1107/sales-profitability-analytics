# E-commerce Sales & Profitability Analytics

**Tools:** Python, PostgreSQL, SQL, Excel, Power BI

## 1. Business Problem
This project analyzes the Olist Brazilian E-Commerce dataset to investigate sales trends, freight costs, and delivery performance. The objective is to understand shipping-cost patterns that may reduce the amount retained from product sales and to develop data-driven business recommendations.

## 2. Dataset
The project uses the Olist Brazilian E-Commerce Public Dataset from Kaggle. It contains approximately 100,000 orders from 2016–2018 across nine CSV files.

Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## 3. Tools and Technologies
- **Python:** Data loading and preparation
- **PostgreSQL:** Data storage and querying
- **SQL:** Data-quality checks, joins, CTEs, window functions, and business analysis
- **Excel:** Supplementary data analysis
- **Power BI:** Interactive KPI cards and analytical dashboards

## 4. Project Workflow
1. Download and inspect the raw CSV files.
2. Load the data into PostgreSQL using Python, pandas, and SQLAlchemy.
3. Perform data-quality checks for missing values, duplicates, date ranges, and unmatched orders.
4. Write SQL queries to analyze revenue trends, freight costs, product categories, customer reviews, and shipping patterns.
5. Build a three-page Power BI report covering sales overview, sales analysis, and freight analysis.
6. Validate findings and prepare actionable business recommendations.

## 5. Key Business Questions
- How does revenue change month over month?
- What percentage of product price is spent on freight?
- Which states and product categories have higher freight burdens?
- How do same-state and cross-state shipments compare?
- Is late delivery associated with lower customer review scores?

## 6. Important Limitation
The dataset does not contain the actual cost of goods sold. Therefore, true profit and profit margin cannot be calculated. This project uses product price minus freight value as a freight-adjusted revenue proxy, not as actual profit.

## 7. Project Status
The data-loading and SQL analysis workflow has been prepared, and the Power BI dashboard is being developed. Final insights and recommendations will be documented after validating the queries, relationships, and dashboard results.
   


   






 


 



