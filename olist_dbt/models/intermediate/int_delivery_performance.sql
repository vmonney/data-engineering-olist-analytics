WITH reviews_ranked AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                COALESCE(answered_at, reviewed_at) DESC,
                reviewed_at DESC,
                review_id DESC
        ) AS rn
    FROM {{ ref('stg_reviews') }}
),

reviews_primary AS (
    SELECT
        order_id,
        review_score
    FROM reviews_ranked
    WHERE rn = 1
)

SELECT
    oi.seller_id,
    s.city AS seller_city,
    s.state AS seller_state,
    c.state AS customer_state,

    -- Volume
    COUNT(DISTINCT o.order_id) AS nb_orders,

    -- Délais
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    ROUND(MEDIAN(o.delivery_days), 1) AS median_delivery_days,
    PERCENTILE_CONT(0.95) WITHIN GROUP (
        ORDER BY o.delivery_days)
        AS p95_delivery_days,

    -- Retards
    SUM(CASE WHEN o.is_late_delivery THEN 1 ELSE 0 END) AS nb_late,
    ROUND(
        SUM(CASE WHEN o.is_late_delivery THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS late_pct,

    -- Satisfaction
    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM {{ ref('stg_order_items') }} AS oi
INNER JOIN {{ ref('stg_orders') }} AS o ON oi.order_id = o.order_id
INNER JOIN {{ ref('stg_sellers') }} AS s ON oi.seller_id = s.seller_id
INNER JOIN {{ ref('stg_customers') }} AS c ON o.customer_id = c.customer_id
LEFT JOIN reviews_primary AS r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1, 2, 3, 4
