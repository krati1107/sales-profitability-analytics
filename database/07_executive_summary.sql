
-- 1. Overall business performance

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    ROUND(SUM(oi.price)::numeric, 2) AS total_product_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight,
    ROUND(
        (
            SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS sales_per_order
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id;


-- 2. Delivered versus non-delivered orders

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        (
            COUNT(*) * 100.0
            / SUM(COUNT(*)) OVER ()
        )::numeric,
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 3. Monthly product sales and order count

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_sales
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY sales_month;
