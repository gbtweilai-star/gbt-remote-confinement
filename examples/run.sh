#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
PYTHONPATH=src python -m gbt_remote_confinement info
PYTHONPATH=src python -m gbt_remote_confinement check --payload '{}'
PYTHONPATH=src python -m gbt_remote_confinement run   --payload '{}'
