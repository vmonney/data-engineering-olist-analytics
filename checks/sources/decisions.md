# Data Quality Threshold Decisions

## Prices > 5,000 BRL in raw_order_items
- Investigated on 2026-02-23 in Marimo notebook
- 3 rows affected: high-end electronics and art items
- Decision: values are legitimate; warn threshold maintained at 10,000 BRL

## Payment vs. item total mismatch > 1 BRL
- Observed value: 250 orders
- Decision: control threshold set to `< 1,000` to remain strict without blocking the pipeline
- Rationale: historical public dataset — rounding differences and partial refunds are expected

## Delivered orders with no recorded payment
- Observed value: 1 order
- Decision: control threshold set to `< 10`
- Rationale: keep the check sensitive while tolerating a single isolated anomaly in the raw dataset

## Duplicate review_id
- Observed value: 789 duplicate `review_id` values
- Decision: control threshold set to `< 1,000`
- Rationale: known artifact of the Olist dataset; monitored but non-blocking
