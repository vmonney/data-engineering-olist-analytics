WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_geolocation') }}
)

SELECT
    geolocation_state AS state,
    CAST(geolocation_zip_code_prefix AS VARCHAR) AS zip_code,
    CAST(geolocation_lat AS DOUBLE) AS latitude,
    CAST(geolocation_lng AS DOUBLE) AS longitude,
    TRIM(LOWER(geolocation_city)) AS city
FROM source
