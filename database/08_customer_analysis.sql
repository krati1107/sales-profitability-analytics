
-- 1. Repeat customers versus one-time customers

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type
ORDER BY total_customers DESC;


-- 2. Top 10 customers by product sales

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_product_sales
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_product_sales DESC
LIMIT 10;


-- 3. Monthly new customers

SELECT
    DATE_TRUNC('month', first_order_date)::date AS first_order_month,
    COUNT(*) AS new_customers
FROM (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp) AS first_order_date
    FROM orders
    GROUP BY customer_id
) AS customer_first_orders
GROUP BY DATE_TRUNC('month', first_order_date)
ORDER BY first_order_month;
