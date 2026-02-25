WITH customer_metrics AS (
    SELECT
        customer_unique_id,
        MIN(customer_state) AS customer_state,
        MIN(customer_city) AS customer_city,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(order_total), 2) AS monetary,
        MAX(purchased_at) AS last_purchase_at,
        MIN(purchased_at) AS first_purchase_at,
        DATE_DIFF('day', MAX(purchased_at), TIMESTAMP '2018-09-01')
            AS recency_days,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        ROUND(AVG(delivery_days), 1) AS avg_delivery_days
    FROM {{ ref('int_orders_enriched') }}
    WHERE order_status = 'delivered'
    GROUP BY 1
),

scored AS (
    SELECT
        *,
        -- Score RFM (1-5 par quintile)
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score
    FROM customer_metrics
)

SELECT
    *,
    r_score + f_score + m_score AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN
            r_score <= 2 AND f_score <= 2 AND m_score >= 3
            THEN 'Big Spenders Lost'
        WHEN r_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END AS rfm_segment
FROM scored
