import marimo

__generated_with = "0.20.1"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import duckdb

    con = duckdb.connect("data/olist.duckdb", read_only=True)

    return con, mo


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## Distribution des statuts
    """)
    return


@app.cell
def _(con, mo, raw_orders):
    _df = mo.sql(
        """
        SELECT
            order_status,
            COUNT(*) AS nb,
            CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),1), ' %') AS pct
        FROM raw_orders
        GROUP BY order_status
        ORDER BY nb DESC
        """,
        engine=con,
    )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## Revenu Mensuel
    """)
    return


@app.cell
def _(con, mo, raw_order_items, raw_orders):
    _df = mo.sql(
        """
        SELECT
        	DATE_TRUNC('month', o.order_purchase_timestamp) AS mois,
            COUNT(DISTINCT o.order_id) AS nb_commandes,
            ROUND(SUM(oi.price + oi.freight_value),2) AS revenu_total,
            ROUND(AVG(oi.price), 2) AS panier_moyen
        FROM raw_orders o
        JOIN raw_order_items oi on o.order_id = oi.order_id
        WHERE order_status = 'delivered'
        GROUP BY mois
        ORDER BY mois
        """,
        engine=con,
    )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    - Croissance nette de sept 2016 à août 2018
    - Pic en novembre 2017 (Black Friday brésilien)
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## Top 10 états par volume
    """)
    return


@app.cell
def _(con, mo, raw_customers, raw_order_items, raw_orders):
    _df = mo.sql(
        """
        SELECT 
            c.customer_state,
            COUNT(DISTINCT o.order_id) AS nb_commandes,
            ROUND(SUM(oi.price), 2) AS revenue,
            ROUND(SUM(oi.price) * 100.0 / SUM(SUM(oi.price)) OVER (), 2) AS pct_revenue
        FROM raw_orders o
        JOIN raw_customers c ON o.customer_id = c.customer_id
        JOIN raw_order_items oi ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_state
        ORDER BY revenue DESC
        LIMIT 10;

        """,
        engine=con,
    )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    - São Paulo (SP) domine massivement (~40% du CA)
    - Rio de Janeiro (RJ) en 2ème (~13%)
    - Minas Gerais (MG) en 3ème (~12%)
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## Distribution des notes
    """)
    return


@app.cell
def _(con, mo, raw_order_reviews):
    _df = mo.sql(
        """
        SELECT
            review_score,
            COUNT(*) AS nb,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
        FROM raw_order_reviews
        GROUP BY review_score
        ORDER BY review_score
        """,
        engine=con,
    )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    - Note 5 : ~57%, Note 4 : ~19%, Note 1 : ~12%
    - Distribution bimodale (très satisfait OU très mécontent)


    ## Résultats clés de l'exploration :

    - 99k commandes, 97% livrées, croissance mensuelle régulière
    - Black Friday 2017 = pic de volume visible
    - São Paulo concentre ~40% du CA
    - Notes clients bimodales : beaucoup de 5/5 et un cluster de 1/5
    - Le délai de livraison semble être le facteur n°1 d'insatisfaction
    """)
    return


if __name__ == "__main__":
    app.run()
