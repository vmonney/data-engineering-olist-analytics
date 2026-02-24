WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_sellers') }}
)

SELECT
    seller_id,
    seller_state AS state,
    CAST(seller_zip_code_prefix AS VARCHAR) AS zip_code,
    TRIM(LOWER(seller_city)) AS city
FROM source
