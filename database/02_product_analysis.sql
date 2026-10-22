
-- 1. Top 10 product categories by sales

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    ROUND(SUM(oi.price)::numeric, 2) AS total_sales,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY total_sales DESC
LIMIT 10;


-- 2. Top 10 products by sales

SELECT
    oi.product_id,
    ROUND(SUM(oi.price)::numeric, 2) AS total_sales,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items AS oi
GROUP BY oi.product_id
ORDER BY total_sales DESC
LIMIT 10;
