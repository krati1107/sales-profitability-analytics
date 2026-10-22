
-- 1. Customers and orders by state

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 2. Product sales by customer state

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_product_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_product_sales DESC;


-- 3. Average freight as a percentage of product price by state

SELECT
    c.customer_state,
    ROUND(SUM(oi.price)::numeric, 2) AS total_product_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight,
    ROUND(
        (
            SUM(oi.freight_value) * 100.0
            / NULLIF(SUM(oi.price), 0)
        )::numeric,
        2
    ) AS freight_percentage
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
HAVING SUM(oi.price) > 0
ORDER BY freight_percentage DESC;
