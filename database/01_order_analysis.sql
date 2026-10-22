--analyze order status--
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

--check total sales--

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS total_product_sales,
    ROUND(SUM(freight_value)::numeric, 2) AS total_freight
FROM order_items;


-- 3. Analyze monthly sales trend

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY sales_month;
