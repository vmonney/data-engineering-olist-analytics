# Evidence Setup (Olist Analytics)

Guide rapide pour lancer le dashboard Evidence dans ce repo.

## Prerequisites

- Node.js `>=18`
- `npm`
- Base de donnees DuckDB du projet disponible a `../data/olist.duckdb`

## 1) Installer les dependances Evidence

Depuis `evidence-report/` :

```bash
npm install
```

## 2) Configurer la source DuckDB

Le fichier de connexion est:

- `sources/needful_things/connection.yaml`

Contenu attendu:

```yaml
name: needful_things
type: duckdb
options:
  filename: needful_things.duckdb
```

### Faut-il copier la base dans `sources/` ?

Non, ce n'est **pas obligatoire**.

- **Option A (recommandee): copier la base dans `sources/needful_things/`**
  - Simple, portable, plus robuste en CI/deploiement.
- **Option B (sans copie): pointer vers un chemin existant**
  - Utile en environnement entreprise quand la copie est interdite.
  - Exemple (chemin relatif depuis `evidence-report/`) :

```yaml
name: needful_things
type: duckdb
options:
  filename: ../data/olist.duckdb
```

Tu peux aussi utiliser un chemin absolu si necessaire.

## 3) Ajouter les source queries

Evidence a besoin de requetes SQL dans `sources/needful_things/*.sql`.
Sans ces fichiers, `npm run sources` peut ne rien generer.

Creer les fichiers suivants:

- `sources/needful_things/mart_daily_revenue.sql`
- `sources/needful_things/mart_delivery_analysis.sql`
- `sources/needful_things/mart_customer_rfm.sql`
- `sources/needful_things/mart_product_analytics.sql`

Contenu (adapter le nom de table):

```sql
select * from main.mart_daily_revenue
```

Exemples:

```sql
-- mart_delivery_analysis.sql
select * from main.mart_delivery_analysis

-- mart_customer_rfm.sql
select * from main.mart_customer_rfm

-- mart_product_analytics.sql
select * from main.mart_product_analytics
```

## 4) Generer les sources (et le manifest)

```bash
npm run sources
```

Cette commande genere le cache de donnees Evidence, dont `data/manifest.json`.

## 5) Lancer le dashboard

```bash
npm run dev
```

Puis ouvrir `http://localhost:3000`.

## 6) Build de production

```bash
npm run build
```

## Troubleshooting

### Erreur: `Unable to load source manifest` / `data/manifest.json 404`

Verifier dans cet ordre:

1. Le fichier `connection.yaml` pointe vers une base DuckDB existante.
2. Les fichiers `sources/needful_things/*.sql` existent.
3. Executer `npm run sources`.
4. Relancer `npm run dev`.

### Erreur de table introuvable

- Verifier que les marts existent dans la base:
  - `main.mart_daily_revenue`
  - `main.mart_delivery_analysis`
  - `main.mart_customer_rfm`
  - `main.mart_product_analytics`
- Si besoin, rebuilder dbt depuis la racine du repo:

```bash
uv run dbt run --project-dir olist_dbt/
```
# Evidence Template Project

## Using Codespaces

If you are using this template in Codespaces, click the `Start Evidence` button in the bottom status bar. This will install dependencies and open a preview of your project in your browser - you should get a popup prompting you to open in browser.

Or you can use the following commands to get started:

```bash
npm install
npm run sources
npm run dev -- --host 0.0.0.0
```

See [the CLI docs](https://docs.evidence.dev/cli/) for more command information.

**Note:** Codespaces is much faster on the Desktop app. After the Codespace has booted, select the hamburger menu → Open in VS Code Desktop.

## Get Started from VS Code

The easiest way to get started is using the [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Evidence.evidence-vscode):



1. Install the extension from the VS Code Marketplace
2. Open the Command Palette (Ctrl/Cmd + Shift + P) and enter `Evidence: New Evidence Project`
3. Click `Start Evidence` in the bottom status bar

## Get Started using the CLI

```bash
npx degit evidence-dev/template my-project
cd my-project 
npm install 
npm run sources
npm run dev 
```

Check out the docs for [alternative install methods](https://docs.evidence.dev/getting-started/install-evidence) including Docker, Github Codespaces, and alongside dbt.



## Learning More

- [Docs](https://docs.evidence.dev/)
- [Github](https://github.com/evidence-dev/evidence)
- [Slack Community](https://slack.evidence.dev/)
- [Evidence Home Page](https://www.evidence.dev)
