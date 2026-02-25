select
    delivery_bucket,
    is_late_delivery,
    nb_orders,
    avg_review_score,
    avg_order_value,
    pct_5stars,
    pct_1star,
    pct_with_comment
from main.mart_delivery_analysis
