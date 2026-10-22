
-- 1. Customer review score distribution

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- 2. Average review score by order status

SELECT
    o.order_status,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS average_review_score
FROM orders AS o
JOIN order_reviews AS r
    ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY average_review_score ASC;


-- 3. Delivery performance for delivered orders

SELECT
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              <= order_estimated_delivery_date
    ) AS on_time_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              > order_estimated_delivery_date
    ) AS late_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
