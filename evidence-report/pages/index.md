# 🇧🇷 Olist E-Commerce Analytics

```sql monthly 
SELECT
    revenue_month AS mois,
    SUM(total_orders) AS commandes,
    ROUND(SUM(total_revenue), 0) AS revenue,
    ROUND(AVG(avg_order_value), 0) AS panier_moyen,
    ROUND(AVG(avg_review_score), 2) AS note_moyenne
FROM mart_daily_revenue
GROUP BY mois
ORDER BY mois
```

<LineChart
    data={monthly}
    x=mois
    y=revenue
    title="Revenue mensuelle (BRL)"
    yFmt=num0
/>

<BarChart
    data={monthly}
    x=mois
    y=commandes
    title="Commandes par mois"
/>

---

## Impact de la livraison sur la satisfaction

```sql delivery_impact
SELECT * FROM mart_delivery_analysis
WHERE NOT is_late_delivery
ORDER BY delivery_bucket
```


<BarChart
    data={delivery_impact}
    x=delivery_bucket
    y=avg_review_score
    title="Note moyenne par délai de livraison"
    yMin=1
    yMax=5
/>

> **Insight clé** : chaque semaine de délai supplémentaire coûte ~0.5 point
> de satisfaction. Les livraisons > 30 jours ont 45% de notes 1★.

---

## Segmentation clients (RFM)

```sql segments
SELECT
    rfm_segment,
    COUNT(*) AS nb_clients,
    ROUND(AVG(monetary), 0) AS panier_moyen,
    ROUND(AVG(frequency), 1) AS commandes_avg
FROM mart_customer_rfm
GROUP BY 1
ORDER BY 2 DESC
```

<BarChart
    data={segments}
    x=rfm_segment
    y=nb_clients
    title="Répartition des segments clients"
    swapXY=true
/>

---

## Top catégories produits

```sql categories
SELECT
    product_category_name AS categorie,
    SUM(total_revenue) AS revenue,
    ROUND(AVG(avg_review), 2) AS note,
    SUM(nb_orders) AS commandes
FROM mart_product_analytics
WHERE product_category_name IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15
```

<BarChart
    data={categories}
    x=categorie
    y=revenue
    title="Top 15 catégories par revenue"
    swapXY=true
    yFmt=num0
/>