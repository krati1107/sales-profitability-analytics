-- =====================================================================
-- 01_setup_and_quality_checks.sql   (MySQL 8+)
-- Run this ONCE after load_data.py
-- =====================================================================
USE ecommerce;

-- ---------------------------------------------------------------------
-- PART 1: INDEXES (make joins fast). Run once only.
-- ---------------------------------------------------------------------
CREATE INDEX idx_orders_id        ON orders(order_id);
CREATE INDEX idx_orders_customer  ON orders(customer_id);
CREATE INDEX idx_items_order      ON order_items(order_id);
CREATE INDEX idx_items_product    ON order_items(product_id);
CREATE INDEX idx_items_seller     ON order_items(seller_id);
CREATE INDEX idx_customers_id     ON customers(customer_id);
CREATE INDEX idx_products_id      ON products(product_id);
CREATE INDEX idx_sellers_id       ON sellers(seller_id);
CREATE INDEX idx_payments_order   ON order_payments(order_id);
CREATE INDEX idx_reviews_order    ON order_reviews(order_id);
CREATE INDEX idx_cat_name         ON category_translation(product_category_name);
CREATE INDEX idx_prod_cat         ON products(product_category_name);

-- ---------------------------------------------------------------------
-- PART 2: DATA QUALITY CHECKS
-- Write down what you find. Interviewers love this.
-- ---------------------------------------------------------------------

-- 2.1 Row count of every table
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_items',          COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments',       COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',        COUNT(*) FROM order_reviews
UNION ALL SELECT 'customers',            COUNT(*) FROM customers
UNION ALL SELECT 'products',             COUNT(*) FROM products
UNION ALL SELECT 'sellers',              COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation',          COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;

-- 2.2 Order status distribution (we analyse only 'delivered')
SELECT order_status,
       COUNT(*) AS orders,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 2.3 Date range of the data
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- 2.4 Orders per month (look at the first and last months: they are small.
--     That is why our trend queries use 2017-01 to 2018-08 only.)
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month, COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;

-- 2.5 NULL check on important columns
SELECT
  SUM(order_delivered_customer_date IS NULL) AS null_delivery_date,
  SUM(order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM orders;

SELECT
  SUM(product_category_name IS NULL) AS null_category,
  SUM(product_weight_g IS NULL)      AS null_weight
FROM products;

-- 2.6 Duplicate check: order_id must be unique in orders
SELECT order_id, COUNT(*) AS c
FROM orders
GROUP BY order_id
HAVING c > 1;

-- 2.7 Orders that have no items (should be 0 or very few)
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- 2.8 Price and freight sanity check (negative or zero values?)
SELECT MIN(price) AS min_price, MAX(price) AS max_price,
       MIN(freight_value) AS min_freight, MAX(freight_value) AS max_freight,
       SUM(freight_value = 0) AS zero_freight_rows
FROM order_items;

-- 2.9 Products with a category that has no English translation
SELECT COUNT(*) AS products_without_translation
FROM products p
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- ---------------------------------------------------------------------
-- PART 3: CLEAN ANALYSIS VIEW  (one row = one item in a delivered order)
-- All analysis queries and Power BI use this view.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_sales AS
SELECT
    o.order_id,
    DATE(o.order_purchase_timestamp)                       AS order_date,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')       AS month_key,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(o.order_delivered_customer_date,
             o.order_purchase_timestamp)                   AS delivery_days,
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 1 ELSE 0 END                                 AS is_late,
    c.customer_unique_id,
    c.customer_state,
    CASE
        WHEN c.customer_state IN ('AC','AP','AM','PA','RO','RR','TO')       THEN 'North'
        WHEN c.customer_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Northeast'
        WHEN c.customer_state IN ('DF','GO','MT','MS')                      THEN 'Central-West'
        WHEN c.customer_state IN ('ES','MG','RJ','SP')                      THEN 'Southeast'
        WHEN c.customer_state IN ('PR','RS','SC')                           THEN 'South'
        ELSE 'Unknown'
    END                                                    AS region,
    oi.seller_id,
    s.seller_state,
    oi.product_id,
    COALESCE(t.product_category_name_english,
             p.product_category_name, 'unknown')           AS category,
    p.product_weight_g,
    oi.price,
    oi.freight_value,
    (oi.price - oi.freight_value)                          AS net_after_freight
FROM orders o
JOIN order_items oi        ON o.order_id = oi.order_id
JOIN customers c           ON o.customer_id = c.customer_id
LEFT JOIN products p       ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
LEFT JOIN sellers s        ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- Quick test: should return thousands of rows
SELECT COUNT(*) AS rows_in_view FROM vw_sales;
