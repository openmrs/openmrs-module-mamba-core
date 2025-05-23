#!/bin/bash
set -euo pipefail

if [[ ! -x ./compile-base.sh ]]; then
  echo "Error: compile-base.sh not found or not executable." >&2
  exit 1
fi

./compile-base.sh "$@"