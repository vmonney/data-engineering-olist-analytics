WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_order_payments') }}
)

SELECT
    order_id,
    payment_type,
    CAST(payment_sequential AS INTEGER) AS payment_sequential,
    CAST(payment_installments AS INTEGER) AS payment_installments,
    ROUND(CAST(payment_value AS DECIMAL(10, 2)), 2) AS payment_value
FROM source
