WITH delivery_buckets AS (
    SELECT
        *,
        CASE
            WHEN delivery_days <= 7 THEN '01. ≤ 7 jours'
            WHEN delivery_days <= 14 THEN '02. 8-14 jours'
            WHEN delivery_days <= 21 THEN '03. 15-21 jours'
            WHEN delivery_days <= 30 THEN '04. 22-30 jours'
            ELSE '05. > 30 jours'
        END AS delivery_bucket
    FROM {{ ref('int_orders_enriched') }}
    WHERE
        order_status = 'delivered'
        AND delivery_days IS NOT NULL
)

SELECT
    delivery_bucket,
    is_late_delivery,

    COUNT(*) AS nb_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(order_total), 2) AS avg_order_value,

    -- Distribution des notes
    ROUND(
        SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS pct_5stars,
    ROUND(
        SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS pct_1star,

    -- % avec commentaire (les mécontents commentent plus)
    ROUND(SUM(CASE WHEN has_comment THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)
        AS pct_with_comment

FROM delivery_buckets
GROUP BY 1, 2
ORDER BY 1, 2
