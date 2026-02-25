from __future__ import annotations

import subprocess
from pathlib import Path

from dagster import (
    AssetSelection,
    Definitions,
    ScheduleDefinition,
    asset,
    define_asset_job,
)

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PYTHON = "python"


def _run(command: list[str], cwd: Path | None = None) -> str:
    """Run a command and return stdout, with readable errors."""
    result = subprocess.run(
        command,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            "Command failed:\n"
            f"{' '.join(command)}\n\n"
            f"stdout:\n{result.stdout}\n"
            f"stderr:\n{result.stderr}"
        )
    return result.stdout


@asset(group_name="ingestion")
def raw_parquet_files() -> None:
    """Extraction CSV -> DuckDB raw tables."""
    _run([PYTHON, "scripts/ingest_csv_to_parquet.py"], cwd=PROJECT_ROOT)


@asset(group_name="quality", deps=[raw_parquet_files])
def source_quality_checks() -> None:
    """Run Soda checks on raw/source data."""
    output = _run(
        [
            "uv",
            "run",
            "soda",
            "scan",
            "-d",
            "duckdb_raw",
            "-c",
            "soda/config.yml",
            "checks/sources/",
        ],
        cwd=PROJECT_ROOT,
    )

    # Soda can report FAIL in stdout depending on check configuration.
    if "FAIL" in output:
        raise RuntimeError(f"Soda source checks failed:\n{output}")


@asset(group_name="transformation", deps=[source_quality_checks])
def dbt_models() -> None:
    """Run dbt transformations then dbt tests."""
    _run(["uv", "run", "dbt", "run", "--project-dir", "olist_dbt/"], cwd=PROJECT_ROOT)
    _run(["uv", "run", "dbt", "test", "--project-dir", "olist_dbt/"], cwd=PROJECT_ROOT)


@asset(group_name="quality", deps=[dbt_models])
def mart_quality_checks() -> None:
    """Run Soda checks on marts after transformation."""
    _run(
        [
            "uv",
            "run",
            "soda",
            "scan",
            "-d",
            "duckdb_raw",
            "-c",
            "soda/config.yml",
            "checks/marts/",
        ],
        cwd=PROJECT_ROOT,
    )


@asset(group_name="reporting", deps=[mart_quality_checks])
def evidence_build() -> None:
    """Build the Evidence dashboard."""
    _run(["npm", "run", "build"], cwd=PROJECT_ROOT / "evidence-report")


daily_pipeline = define_asset_job(
    "daily_pipeline",
    selection=AssetSelection.all(),
)

daily_schedule = ScheduleDefinition(
    job=daily_pipeline,
    cron_schedule="0 6 * * *",
)

defs = Definitions(
    assets=[
        raw_parquet_files,
        source_quality_checks,
        dbt_models,
        mart_quality_checks,
        evidence_build,
    ],
    jobs=[daily_pipeline],
    schedules=[daily_schedule],
)
