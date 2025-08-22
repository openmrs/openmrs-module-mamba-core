#!/bin/bash

# Enable strict error handling
set -euo pipefail
IFS=$'\n\t'

# Get the directory of this script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call compile-base.sh with all arguments properly quoted
"${SCRIPT_DIR}/compile-base.sh" "$@"