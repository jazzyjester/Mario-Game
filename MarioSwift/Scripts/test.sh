#!/bin/sh
# Runs the test suite. Needed because this machine has Command Line Tools only
# (no Xcode), and SwiftPM doesn't add the CLT's Testing.framework paths itself.
set -eu
cd "$(dirname "$0")/.."

FW=/Library/Developer/CommandLineTools/Library/Developer/Frameworks
LIB=/Library/Developer/CommandLineTools/Library/Developer/usr/lib

exec swift test \
  -Xswiftc -F"$FW" \
  -Xlinker -F"$FW" \
  -Xlinker -rpath -Xlinker "$FW" \
  -Xlinker -rpath -Xlinker "$LIB" \
  "$@"
