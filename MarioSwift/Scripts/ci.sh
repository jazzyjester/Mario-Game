#!/bin/sh
# Build + full test suite. Usable locally and in CI.
set -eu
cd "$(dirname "$0")/.."

swift build
exec "$(dirname "$0")/test.sh"
