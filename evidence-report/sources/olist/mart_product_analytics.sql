select
    product_id,
    product_category_name,
    product_weight_g,
    nb_orders,
    total_units_sold,
    total_revenue,
    avg_price,
    avg_freight,
    freight_pct_of_price,
    avg_review,
    nb_1star,
    revenue_rank
from main.mart_product_analytics
