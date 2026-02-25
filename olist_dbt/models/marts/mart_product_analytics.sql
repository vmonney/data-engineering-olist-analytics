SELECT
    p.product_id,
    p.product_category_name,
    p.product_weight_g,

    -- Volume
    COUNT(DISTINCT oi.order_id) AS nb_orders,
    SUM(oi.order_item_id) AS total_units_sold,
    ROUND(SUM(oi.item_price), 2) AS total_revenue,
    ROUND(AVG(oi.item_price), 2) AS avg_price,

    -- Fret (corrélation poids/coût)
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(
        CASE
            WHEN
                AVG(oi.item_price) >= 10
                AND COUNT(*) >= 5
                THEN
                    AVG(oi.freight_value) / NULLIF(AVG(oi.item_price), 0) * 100
        END,
        1
    ) AS freight_pct_of_price,

    -- Satisfaction
    ROUND(AVG(r.review_score), 2) AS avg_review,
    COUNT(CASE WHEN r.review_score = 1 THEN 1 END) AS nb_1star,

    -- Ranking
    ROW_NUMBER() OVER (
        ORDER BY SUM(oi.item_price) DESC
    ) AS revenue_rank

FROM {{ ref('stg_products') }} AS p
INNER JOIN {{ ref('stg_order_items') }} AS oi ON p.product_id = oi.product_id
INNER JOIN {{ ref('stg_orders') }} AS o ON oi.order_id = o.order_id
LEFT JOIN {{ ref('stg_reviews') }} AS r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1, 2, 3
