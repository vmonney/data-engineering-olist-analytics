WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_orders') }}
),

cleaned AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        CAST(order_purchase_timestamp AS TIMESTAMP) AS purchased_at,
        CAST(order_approved_at AS TIMESTAMP) AS approved_at,
        CAST(order_delivered_carrier_date AS TIMESTAMP) AS shipped_at,
        CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_at,
        CAST(order_estimated_delivery_date AS TIMESTAMP)
            AS estimated_delivery_at,

        -- Métriques dérivées (en jours)
        DATE_DIFF(
            'day',
            CAST(order_purchase_timestamp AS TIMESTAMP),
            CAST(order_delivered_customer_date AS TIMESTAMP)
        ) AS delivery_days,

        DATE_DIFF(
            'day',
            CAST(order_purchase_timestamp AS TIMESTAMP),
            CAST(order_estimated_delivery_date AS TIMESTAMP)
        ) AS estimated_delivery_days,

        -- Flag : livré en retard ?
        COALESCE(
            order_delivered_customer_date > order_estimated_delivery_date, FALSE
        ) AS is_late_delivery

    FROM source
    WHERE order_status NOT IN ('created', 'approved')
    -- On exclut les 7 commandes jamais traitées
)

SELECT * FROM cleaned
