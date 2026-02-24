WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_order_items') }}
)

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    ROUND(CAST(price AS DECIMAL(10, 2)), 2) AS item_price,
    ROUND(CAST(freight_value AS DECIMAL(10, 2)), 2) AS freight_value,
    ROUND(
        CAST(price AS DECIMAL(10, 2)) + CAST(freight_value AS DECIMAL(10, 2)), 2
    )
        AS total_item_value,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_at
FROM source
