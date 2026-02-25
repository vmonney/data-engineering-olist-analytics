WITH delivered_orders AS (
    SELECT
        DATE_TRUNC('day', purchased_at) AS revenue_date,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_unique_id) AS unique_customers,
        SUM(nb_items) AS total_items_sold,
        ROUND(SUM(total_price), 2) AS gross_revenue,
        ROUND(SUM(total_freight), 2) AS total_freight_revenue,
        ROUND(SUM(order_total), 2) AS total_revenue,
        ROUND(AVG(order_total), 2) AS avg_order_value,
        ROUND(AVG(nb_items), 1) AS avg_items_per_order,
        ROUND(AVG(review_score), 2) AS avg_review_score
    FROM {{ ref('int_orders_enriched') }}
    WHERE order_status = 'delivered'
    GROUP BY 1
),

date_bounds AS (
    SELECT
        MIN(revenue_date) AS min_revenue_date,
        MAX(revenue_date) AS max_revenue_date
    FROM delivered_orders
),

date_spine AS (
    SELECT generate_series AS revenue_date
    FROM date_bounds,
        GENERATE_SERIES(min_revenue_date, max_revenue_date, INTERVAL 1 DAY)
)

SELECT -- noqa: ST06
    ds.revenue_date,
    DATE_TRUNC('week', ds.revenue_date) AS revenue_week,
    DATE_TRUNC('month', ds.revenue_date) AS revenue_month,
    COALESCE(d.total_orders, 0) AS total_orders,
    COALESCE(d.unique_customers, 0) AS unique_customers,
    COALESCE(d.total_items_sold, 0) AS total_items_sold,
    COALESCE(d.gross_revenue, 0) AS gross_revenue,
    COALESCE(d.total_freight_revenue, 0) AS total_freight_revenue,
    COALESCE(d.total_revenue, 0) AS total_revenue,
    d.avg_order_value,
    d.avg_items_per_order,
    d.avg_review_score
FROM date_spine AS ds
LEFT JOIN delivered_orders AS d
    ON ds.revenue_date = d.revenue_date
ORDER BY 1
