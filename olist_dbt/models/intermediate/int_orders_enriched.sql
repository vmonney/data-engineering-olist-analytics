WITH order_totals AS (
    SELECT
        order_id,
        COUNT(*) AS nb_items,
        SUM(item_price) AS total_price,
        SUM(freight_value) AS total_freight,
        SUM(total_item_value) AS order_total,
        COUNT(DISTINCT seller_id) AS nb_sellers,
        COUNT(DISTINCT product_id) AS nb_distinct_products
    FROM {{ ref('stg_order_items') }}
    GROUP BY 1
),

payment_ranked AS (
    SELECT
        order_id,
        payment_type,
        payment_sequential,
        payment_installments,
        payment_value,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC, payment_sequential ASC
        ) AS rn
    FROM {{ ref('stg_payments') }}
),

payment_totals AS (
    SELECT
        order_id,
        COUNT(*) AS nb_payments,
        MAX(payment_installments) AS max_installments,
        SUM(payment_value) AS total_paid
    FROM {{ ref('stg_payments') }}
    GROUP BY 1
),

payment_primary AS (
    SELECT
        order_id,
        payment_type AS primary_payment_type,
        payment_sequential AS primary_payment_sequential,
        payment_installments AS primary_payment_installments
    FROM payment_ranked
    WHERE rn = 1
),

reviews_ranked AS (
    SELECT
        order_id,
        review_score,
        review_sentiment,
        has_comment,
        comment_length,
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
        review_score,
        review_sentiment,
        has_comment,
        comment_length
    FROM reviews_ranked
    WHERE rn = 1
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.city AS customer_city,
    c.state AS customer_state,

    -- Timestamps
    o.purchased_at,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,
    o.order_status,

    -- Livraison
    o.delivery_days,
    o.estimated_delivery_days,
    o.is_late_delivery,
    ot.nb_items,

    -- Montants
    ot.total_price,
    ot.total_freight,
    ot.order_total,
    ot.nb_sellers,
    ot.nb_distinct_products,
    pt.nb_payments,

    -- Paiement
    pp.primary_payment_type,
    pp.primary_payment_sequential,
    pp.primary_payment_installments,
    pt.max_installments,
    pt.total_paid,
    r.review_score,

    -- Review
    r.review_sentiment,
    r.has_comment,
    r.comment_length,
    o.delivery_days - o.estimated_delivery_days AS delivery_delta_days

FROM {{ ref('stg_orders') }} AS o
LEFT JOIN {{ ref('stg_customers') }} AS c ON o.customer_id = c.customer_id
LEFT JOIN order_totals AS ot ON o.order_id = ot.order_id
LEFT JOIN payment_totals AS pt ON o.order_id = pt.order_id
LEFT JOIN payment_primary AS pp ON o.order_id = pp.order_id
LEFT JOIN reviews_primary AS r ON o.order_id = r.order_id
