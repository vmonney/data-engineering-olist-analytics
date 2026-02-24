# checks/sources/decisions.md
## Prix > 5000 BRL dans raw_order_items
- Investigué le 2026-02-23 dans Marimo
- 3 lignes concernées, produits électroniques haut de gamme ou art
- Décision : valeurs légitimes, seuil warn maintenu à 10000 BRL

## Ecart paiement vs total items > 1 BRL
- Valeur observée: 250 commandes
- Décision: seuil de contrôle à `< 1000` pour rester strict sans bloquer le pipeline portfolio
- Raison: dataset public historique avec cas de rounding/remboursements possibles

## Commandes livrées sans paiement
- Valeur observée: 1 commande
- Décision: seuil de contrôle à `< 10`
- Raison: garder le check sensible tout en tolérant une anomalie isolée du dataset brut

## Doublons review_id
- Valeur observée: 789 `review_id` dupliqués
- Décision: seuil de contrôle à `< 1000`
- Raison: anomalie connue du dataset Olist, monitorée mais non bloquante