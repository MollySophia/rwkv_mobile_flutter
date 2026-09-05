#!/bin/sh
set -eu
exec python3 "$(dirname "$0")/tools/fetch_native_libraries.py" "$@"
