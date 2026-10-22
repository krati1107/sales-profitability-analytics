
-- 1. Check duplicate order IDs in the orders table

SELECT
    order_id,
    COUNT(*) AS record_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 2. Check missing values in important order columns

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,
    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_date,
    COUNT(*) FILTER (
        WHERE order_status IS NULL
    ) AS missing_order_status
FROM orders;


-- 3. Check missing prices and freight values

SELECT
    COUNT(*) AS total_order_items,
    COUNT(*) FILTER (
        WHERE price IS NULL
    ) AS missing_prices,
    COUNT(*) FILTER (
        WHERE freight_value IS NULL
    ) AS missing_freight,
    COUNT(*) FILTER (
        WHERE price < 0
    ) AS negative_prices,
    COUNT(*) FILTER (
        WHERE freight_value < 0
    ) AS negative_freight
FROM order_items;


-- 4. Check order items without a matching order

SELECT COUNT(*) AS unmatched_order_items
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 5. Check products without a matching product record

SELECT COUNT(*) AS unmatched_products
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
