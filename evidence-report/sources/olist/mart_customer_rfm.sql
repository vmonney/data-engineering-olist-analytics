select
    customer_unique_id,
    customer_state,
    customer_city,
    frequency,
    monetary,
    last_purchase_at,
    first_purchase_at,
    recency_days,
    avg_review_score,
    avg_delivery_days,
    r_score,
    f_score,
    m_score,
    rfm_total,
    rfm_segment
from main.mart_customer_rfm
