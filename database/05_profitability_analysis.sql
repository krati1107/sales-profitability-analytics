
-- 1. Freight cost as a percentage of product price

SELECT
    ROUND(SUM(price)::numeric, 2) AS total_product_sales,
    ROUND(SUM(freight_value)::numeric, 2) AS total_freight,
    ROUND(
        (
            SUM(freight_value) * 100.0
            / NULLIF(SUM(price), 0)
        )::numeric,
        2
    ) AS freight_percentage
FROM order_items;
