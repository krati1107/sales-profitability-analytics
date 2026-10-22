
-- 1. Top 10 sellers by product sales

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight
FROM order_items AS oi
GROUP BY oi.seller_id
ORDER BY total_sales DESC
LIMIT 10;


-- 2. Sellers with the highest freight burden

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price)::numeric, 2) AS total_sales,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight,
    ROUND(
        (
            SUM(oi.freight_value) * 100.0
            / NULLIF(SUM(oi.price), 0)
        )::numeric,
        2
    ) AS freight_percentage
FROM order_items AS oi
GROUP BY oi.seller_id
HAVING SUM(oi.price) > 0
ORDER BY freight_percentage DESC
LIMIT 10;


-- 3. Seller order volume and average item price

SELECT
    seller_id,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(price)::numeric, 2) AS average_item_price
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;
