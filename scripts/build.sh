#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/haxe"

rm -rf build
mkdir -p build
haxe build.hxml

mkdir -p "$ROOT_DIR/HaxeiOS.playground/Resources"
cp build/main.js "$ROOT_DIR/HaxeiOS.playground/Resources/main.js"

echo "Generated HaxeiOS.playground/Resources/main.js"
