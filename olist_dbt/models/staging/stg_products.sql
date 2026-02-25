WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_products') }}
),

category_translation AS (
    SELECT
        product_category_name,
        product_category_name_english
    FROM {{ ref('product_category_name_translation') }}
)

SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name)
        AS product_category_name,
    CAST(p.product_name_lenght AS INTEGER) AS product_name_length,
    CAST(p.product_description_lenght AS INTEGER) AS product_description_length,
    CAST(p.product_photos_qty AS INTEGER) AS product_photos_qty,
    CAST(p.product_weight_g AS INTEGER) AS product_weight_g,
    CAST(p.product_length_cm AS INTEGER) AS product_length_cm,
    CAST(p.product_height_cm AS INTEGER) AS product_height_cm,
    CAST(p.product_width_cm AS INTEGER) AS product_width_cm
FROM source AS p
LEFT JOIN category_translation AS t
    ON p.product_category_name = t.product_category_name
