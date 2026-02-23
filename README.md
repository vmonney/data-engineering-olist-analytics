# Olist Analytics

## Linting

Install dependencies (including dev tools):

```bash
uv sync --dev
```

Run Ruff (Python):

```bash
uv run ruff check .
uv run ruff format .
```

Auto-fix Ruff issues:

```bash
uv run ruff check . --fix
```

Run SQLFluff (SQL):

```bash
uv run sqlfluff lint . --dialect duckdb
```

Auto-fix SQLFluff issues:

```bash
uv run sqlfluff fix . --dialect duckdb
```

Run both linters via pre-commit:

```bash
uvx pre-commit run --all-files
```
