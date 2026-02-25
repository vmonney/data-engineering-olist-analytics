"""Olist Analytics — CLI entry point.

Usage:
    uv run python main.py ingest       # Load CSVs into DuckDB
    uv run python main.py quality      # Run Soda checks (sources + marts)
    uv run python main.py transform    # Run dbt build (run + test)
    uv run python main.py pipeline     # Full end-to-end pipeline
    uv run python main.py dagster      # Launch Dagster UI
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent


def _run(command: list[str], cwd: Path | None = None) -> int:
    result = subprocess.run(command, cwd=str(cwd) if cwd else None)
    return result.returncode


def cmd_ingest() -> int:
    print(">> Ingesting CSV files into DuckDB...")
    return _run([sys.executable, "scripts/ingest_csv_to_parquet.py"], cwd=PROJECT_ROOT)


def cmd_quality() -> int:
    print(">> Running Soda checks on sources...")
    rc = _run(
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
    if rc != 0:
        return rc
    print(">> Running Soda checks on marts...")
    return _run(
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


def cmd_transform() -> int:
    print(">> Running dbt build (run + test)...")
    return _run(
        ["uv", "run", "dbt", "build", "--project-dir", "olist_dbt/"],
        cwd=PROJECT_ROOT,
    )


def cmd_pipeline() -> int:
    for step in [cmd_ingest, cmd_quality, cmd_transform]:
        rc = step()
        if rc != 0:
            return rc
    return 0


def cmd_dagster() -> int:
    print(">> Starting Dagster UI at http://localhost:3000 ...")
    return _run(
        ["uv", "run", "dagster", "dev", "-m", "pipeline.definitions"],
        cwd=PROJECT_ROOT,
    )


COMMANDS = {
    "ingest": cmd_ingest,
    "quality": cmd_quality,
    "transform": cmd_transform,
    "pipeline": cmd_pipeline,
    "dagster": cmd_dagster,
}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Olist Analytics pipeline CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="\n".join(f"  {k:12} {v.__doc__ or ''}" for k, v in COMMANDS.items()),
    )
    parser.add_argument("command", choices=list(COMMANDS), help="Step to run")
    args = parser.parse_args()
    sys.exit(COMMANDS[args.command]())


if __name__ == "__main__":
    main()
