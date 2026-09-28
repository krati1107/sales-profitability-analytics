-- =====================================================================
-- 02_analysis_queries.sql   (MySQL 8+)
-- 25 queries: KPIs -> Profitability -> Products -> Customers -> Operations
-- Business question: "Why do profit margins fall when sales rise?"
--
-- IMPORTANT NOTES
-- * Olist has NO cost-of-goods data. So we use a PROXY for margin:
--       net_after_freight = price - freight_value
--   and "freight %" = freight_value / price * 100.
--   Say this clearly in your README and in interviews.
-- * Trend queries use 2017-01 to 2018-08 only (other months have very few orders).
-- * The view is at ITEM level, so always use COUNT(DISTINCT order_id) for orders.
-- =====================================================================
USE ecommerce;

-- =====================================================================
-- SECTION A: OVERALL KPIs
-- =====================================================================

-- Q1. Overall KPIs
SELECT COUNT(DISTINCT order_id)                                  AS total_orders,
       COUNT(DISTINCT customer_unique_id)                        AS unique_customers,
       ROUND(SUM(price), 2)                                      AS revenue,
       ROUND(SUM(freight_value), 2)                              AS freight_total,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)           AS freight_pct_of_revenue,
       ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)           AS aov
FROM vw_sales;

-- Q2. Monthly revenue, orders, AOV and freight %
SELECT month_key,
       COUNT(DISTINCT order_id)                          AS orders,
       ROUND(SUM(price), 2)                              AS revenue,
       ROUND(SUM(freight_value), 2)                      AS freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct,
       ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)   AS aov
FROM vw_sales
WHERE month_key BETWEEN '2017-01' AND '2018-08'
GROUP BY month_key
ORDER BY month_key;

-- Q3. Month-over-month revenue growth (window function LAG)
WITH monthly AS (
    SELECT month_key, SUM(price) AS revenue
    FROM vw_sales
    WHERE month_key BETWEEN '2017-01' AND '2018-08'
    GROUP BY month_key
)
SELECT month_key,
       ROUND(revenue, 2) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month_key))
             / LAG(revenue) OVER (ORDER BY month_key) * 100, 1) AS mom_growth_pct
FROM monthly
ORDER BY month_key;

-- Q4. Yearly revenue and orders
SELECT YEAR(order_date) AS year,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue
FROM vw_sales
GROUP BY YEAR(order_date)
ORDER BY year;

-- Q5. Cumulative (running total) revenue
WITH monthly AS (
    SELECT month_key, SUM(price) AS revenue
    FROM vw_sales
    WHERE month_key BETWEEN '2017-01' AND '2018-08'
    GROUP BY month_key
)
SELECT month_key,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month_key), 2) AS running_total
FROM monthly;

-- =====================================================================
-- SECTION B: PROFITABILITY / FREIGHT  (this section finds the root cause)
-- =====================================================================

-- Q6. Freight % by STATE  (main insight query)
SELECT customer_state,
       region,
       COUNT(DISTINCT order_id)                          AS orders,
       ROUND(SUM(price), 2)                              AS revenue,
       ROUND(SUM(freight_value), 2)                      AS freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct
FROM vw_sales
GROUP BY customer_state, region
HAVING orders >= 100                     -- ignore tiny samples
ORDER BY freight_pct DESC;

-- Q7. Freight % by REGION  (check the "North" claim on your resume here!)
SELECT region,
       COUNT(DISTINCT order_id)                          AS orders,
       ROUND(SUM(price), 2)                              AS revenue,
       ROUND(SUM(freight_value), 2)                      AS freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct,
       ROUND(SUM(net_after_freight) / SUM(price) * 100, 1) AS net_margin_proxy_pct
FROM vw_sales
GROUP BY region
ORDER BY freight_pct DESC;

-- Q8. States where freight is MORE than 30% of product price
SELECT customer_state, region,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1) AS freight_pct
FROM vw_sales
GROUP BY customer_state, region
HAVING freight_pct > 30
ORDER BY freight_pct DESC;

-- Q9. Monthly freight % by region (is the problem getting worse over time?)
SELECT month_key,
       ROUND(SUM(CASE WHEN region='North'        THEN freight_value END) /
             SUM(CASE WHEN region='North'        THEN price END) * 100, 1) AS north_pct,
       ROUND(SUM(CASE WHEN region='Northeast'    THEN freight_value END) /
             SUM(CASE WHEN region='Northeast'    THEN price END) * 100, 1) AS northeast_pct,
       ROUND(SUM(CASE WHEN region='Central-West' THEN freight_value END) /
             SUM(CASE WHEN region='Central-West' THEN price END) * 100, 1) AS central_west_pct,
       ROUND(SUM(CASE WHEN region='Southeast'    THEN freight_value END) /
             SUM(CASE WHEN region='Southeast'    THEN price END) * 100, 1) AS southeast_pct,
       ROUND(SUM(CASE WHEN region='South'        THEN freight_value END) /
             SUM(CASE WHEN region='South'        THEN price END) * 100, 1) AS south_pct
FROM vw_sales
WHERE month_key BETWEEN '2017-01' AND '2018-08'
GROUP BY month_key
ORDER BY month_key;

-- Q10. Revenue mix by region (are we growing in the expensive regions?)
SELECT month_key, region,
       ROUND(SUM(price), 2) AS revenue,
       ROUND(SUM(price) * 100 / SUM(SUM(price)) OVER (PARTITION BY month_key), 1) AS share_of_month_pct
FROM vw_sales
WHERE month_key BETWEEN '2017-01' AND '2018-08'
GROUP BY month_key, region
ORDER BY month_key, region;

-- Q11. Freight % by category (only categories with 100+ orders)
SELECT category,
       COUNT(DISTINCT order_id)                          AS orders,
       ROUND(SUM(price), 2)                              AS revenue,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct
FROM vw_sales
GROUP BY category
HAVING orders >= 100
ORDER BY freight_pct DESC
LIMIT 15;

-- Q12. Freight vs product weight bucket
SELECT CASE
           WHEN product_weight_g < 500   THEN '1) under 500 g'
           WHEN product_weight_g < 2000  THEN '2) 500 g - 2 kg'
           WHEN product_weight_g < 5000  THEN '3) 2 - 5 kg'
           WHEN product_weight_g IS NULL THEN '5) unknown'
           ELSE                               '4) over 5 kg'
       END AS weight_bucket,
       COUNT(*)                                          AS items,
       ROUND(AVG(price), 2)                              AS avg_price,
       ROUND(AVG(freight_value), 2)                      AS avg_freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct
FROM vw_sales
GROUP BY weight_bucket
ORDER BY weight_bucket;

-- Q13. Same-state vs cross-state shipping (supports the "local seller" recommendation)
SELECT CASE WHEN seller_state = customer_state THEN 'Same state' ELSE 'Different state' END AS shipping_type,
       COUNT(*)                                          AS items,
       ROUND(AVG(freight_value), 2)                      AS avg_freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct,
       ROUND(AVG(delivery_days), 1)                      AS avg_delivery_days
FROM vw_sales
WHERE seller_state IS NOT NULL
GROUP BY shipping_type;

-- Q14. Where do North-region customers' sellers come from?
SELECT seller_state,
       COUNT(*)                                          AS items,
       ROUND(AVG(freight_value), 2)                      AS avg_freight,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct
FROM vw_sales
WHERE region = 'North' AND seller_state IS NOT NULL
GROUP BY seller_state
ORDER BY items DESC
LIMIT 10;

-- Q15. Problem combinations: region + category with very high freight %
SELECT region, category,
       COUNT(DISTINCT order_id)                          AS orders,
       ROUND(SUM(price), 2)                              AS revenue,
       ROUND(SUM(freight_value) / SUM(price) * 100, 1)   AS freight_pct
FROM vw_sales
GROUP BY region, category
HAVING orders >= 30 AND freight_pct > 30
ORDER BY revenue DESC
LIMIT 20;

-- =====================================================================
-- SECTION C: PRODUCTS
-- =====================================================================

-- Q16. Top 10 categories by revenue with share of total
SELECT category,
       ROUND(SUM(price), 2) AS revenue,
       ROUND(SUM(price) * 100 / SUM(SUM(price)) OVER (), 1) AS share_pct
FROM vw_sales
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q17. Top 3 categories inside each region (RANK + CTE)
WITH ranked AS (
    SELECT region, category,
           SUM(price) AS revenue,
           RANK() OVER (PARTITION BY region ORDER BY SUM(price) DESC) AS rnk
    FROM vw_sales
    GROUP BY region, category
)
SELECT region, category, ROUND(revenue, 2) AS revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY region, rnk;

-- Q18. PRACTICE ANSWER: Top 5 categories by revenue for LATE-delivered orders
SELECT category,
       COUNT(DISTINCT order_id) AS late_orders,
       ROUND(SUM(price), 2)     AS revenue
FROM vw_sales
WHERE is_late = 1
GROUP BY category
ORDER BY revenue DESC
LIMIT 5;

-- =====================================================================
-- SECTION D: CUSTOMERS
-- =====================================================================

-- Q19. Customer Lifetime Value (CLV) = total revenue per unique customer
SELECT COUNT(DISTINCT customer_unique_id)                          AS customers,
       ROUND(SUM(price) / COUNT(DISTINCT customer_unique_id), 2)   AS avg_clv,
       ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)             AS aov
FROM vw_sales;

-- Q20. Top 10 customers by lifetime revenue
SELECT customer_unique_id,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS lifetime_revenue
FROM vw_sales
GROUP BY customer_unique_id
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- Q21. Repeat customer rate (expect a LOW number: most Olist customers buy once)
WITH cust AS (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS orders
    FROM vw_sales
    GROUP BY customer_unique_id
)
SELECT COUNT(*)                                              AS customers,
       SUM(orders > 1)                                       AS repeat_customers,
       ROUND(SUM(orders > 1) * 100 / COUNT(*), 2)            AS repeat_rate_pct
FROM cust;

-- Q22. Customer spend quartiles (NTILE): how much revenue comes from top 25%?
WITH cust AS (
    SELECT customer_unique_id, SUM(price) AS spend
    FROM vw_sales
    GROUP BY customer_unique_id
),
tiles AS (
    SELECT spend, NTILE(4) OVER (ORDER BY spend DESC) AS quartile
    FROM cust
)
SELECT quartile,
       COUNT(*)                                              AS customers,
       ROUND(SUM(spend), 2)                                  AS revenue,
       ROUND(SUM(spend) * 100 / SUM(SUM(spend)) OVER (), 1)  AS revenue_share_pct
FROM tiles
GROUP BY quartile
ORDER BY quartile;

-- =====================================================================
-- SECTION E: SELLERS, DELIVERY, REVIEWS, PAYMENTS
-- =====================================================================

-- Q23. Top 10 sellers by revenue (with rank and share)
SELECT seller_id,
       seller_state,
       ROUND(SUM(price), 2) AS revenue,
       ROUND(SUM(price) * 100 / SUM(SUM(price)) OVER (), 2) AS share_pct,
       DENSE_RANK() OVER (ORDER BY SUM(price) DESC)         AS seller_rank
FROM vw_sales
GROUP BY seller_id, seller_state
ORDER BY revenue DESC
LIMIT 10;

-- Q24. Late delivery rate and average delivery days by region
WITH per_order AS (
    SELECT DISTINCT order_id, region, is_late, delivery_days
    FROM vw_sales
)
SELECT region,
       COUNT(*)                          AS orders,
       ROUND(AVG(delivery_days), 1)      AS avg_delivery_days,
       ROUND(SUM(is_late) * 100 / COUNT(*), 1) AS late_rate_pct
FROM per_order
GROUP BY region
ORDER BY late_rate_pct DESC;

-- Q25. Review score vs delivery status
WITH per_order AS (
    SELECT DISTINCT order_id, is_late FROM vw_sales
),
rev AS (
    SELECT order_id, AVG(review_score) AS score
    FROM order_reviews
    GROUP BY order_id
)
SELECT CASE WHEN p.is_late = 1 THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*)                     AS orders,
       ROUND(AVG(r.score), 2)       AS avg_review_score
FROM per_order p
JOIN rev r ON p.order_id = r.order_id
GROUP BY delivery_status;

-- BONUS Q26. Payment type mix for delivered orders
SELECT op.payment_type,
       COUNT(DISTINCT op.order_id)                       AS orders,
       ROUND(SUM(op.payment_value), 2)                   AS total_paid,
       ROUND(AVG(op.payment_installments), 1)            AS avg_installments
FROM order_payments op
WHERE op.order_id IN (SELECT DISTINCT order_id FROM vw_sales)
GROUP BY op.payment_type
ORDER BY total_paid DESC;
