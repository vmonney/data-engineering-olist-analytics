SELECT
    oi.seller_id,
    s.city AS seller_city,
    s.state AS seller_state,

    -- Volume
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.nb_items) AS total_items,
    ROUND(SUM(o.total_price), 2) AS total_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,

    -- Livraison
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    ROUND(
        SUM(CASE WHEN o.is_late_delivery THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 1
    ) AS late_delivery_pct,

    -- Satisfaction
    ROUND(AVG(o.review_score), 2) AS avg_review_score,
    SUM(CASE WHEN o.review_score <= 2 THEN 1 ELSE 0 END) AS nb_bad_reviews,

    -- Catégorisation
    CASE
        WHEN COUNT(DISTINCT o.order_id) >= 100 AND AVG(o.review_score) >= 4.0
            THEN 'Top Performer'
        WHEN COUNT(DISTINCT o.order_id) >= 50 AND AVG(o.review_score) >= 3.5
            THEN 'Solid'
        WHEN AVG(o.review_score) < 3.0 AND COUNT(DISTINCT o.order_id) >= 20
            THEN 'Needs Improvement'
        ELSE 'Low Volume'
    END AS seller_tier

FROM {{ ref('int_orders_enriched') }} AS o
INNER JOIN {{ ref('stg_order_items') }} AS oi ON o.order_id = oi.order_id
INNER JOIN {{ ref('stg_sellers') }} AS s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY 1, 2, 3
