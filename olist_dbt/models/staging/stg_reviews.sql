WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_order_reviews') }}
)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    CASE
        WHEN review_score >= 4 THEN 'positive'
        WHEN review_score = 3 THEN 'neutral'
        ELSE 'negative'
    END AS review_sentiment,
    LENGTH(review_comment_message) AS comment_length,
    review_comment_message IS NOT NULL AS has_comment,
    CAST(review_creation_date AS TIMESTAMP) AS reviewed_at,
    CAST(review_answer_timestamp AS TIMESTAMP) AS answered_at
FROM source
