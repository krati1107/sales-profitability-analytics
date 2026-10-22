
-- 1. Payment method distribution

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value)::numeric, 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 2. Installment analysis

SELECT
    payment_installments,
    COUNT(*) AS payment_records,
    ROUND(AVG(payment_value)::numeric, 2) AS average_payment,
    ROUND(SUM(payment_value)::numeric, 2) AS total_payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- 3. Average order value (AOV) by month

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(oi.price)::numeric
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY order_month;
