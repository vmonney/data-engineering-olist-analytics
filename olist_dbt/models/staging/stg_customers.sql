WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_customers') }}
)

SELECT
    customer_id,
    customer_unique_id,
    -- Normaliser les noms de villes (minuscules, trim)
    customer_state AS state,
    TRIM(LOWER(customer_city)) AS city,
    CAST(customer_zip_code_prefix AS VARCHAR) AS zip_code
FROM source
