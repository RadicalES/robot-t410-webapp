#!/bin/bash
set -e

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$PROJ/public"
OUT="$PROJ/build"

echo "==> Cleaning build directory..."
rm -rf "$OUT"
mkdir -p "$OUT/layers"

echo "==> Transpiling JS (Babel)..."
npx babel "$SRC/robot.js" "$SRC/validation.js" --out-dir "$OUT" --compact=true --no-comments

echo "==> Minifying CSS..."
npx clean-css-cli -o "$OUT/site.css" "$SRC/site.css"

echo "==> Minifying HTML..."
HTML_OPTS="--collapse-whitespace --remove-comments --remove-redundant-attributes --remove-empty-attributes"
npx html-minifier-terser $HTML_OPTS -o "$OUT/index.html" "$SRC/index.html"
for f in "$SRC"/layers/*.html; do
	npx html-minifier-terser $HTML_OPTS -o "$OUT/layers/$(basename "$f")" "$f"
done

echo "==> Copying assets..."
cp "$SRC/w3.css" "$SRC/favicon.png" "$SRC/robot.png" "$OUT/"

echo "==> Build complete: $OUT"
