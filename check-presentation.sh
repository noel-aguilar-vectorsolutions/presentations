#!/usr/bin/env bash
# Screenshot every slide of a presentation in light and dark mode, and print it to PDF,
# so you can check the layout without clicking through it.
# Usage: ./check-presentation.sh <slug> [WIDTHxHEIGHT]   (default 1600x900, a 16:9 screen)
# Writes tmp/check/<slug>/ (tmp/ is git-ignored). Needs Google Chrome; set CHROME to override its path.
set -euo pipefail

cd "$(dirname "$0")"

slug="${1:-}"
size="${2:-1600x900}"
if [[ -z "$slug" || ! -f "$slug/index.html" ]]; then
  echo "Usage: $0 <slug> [WIDTHxHEIGHT]" >&2
  exit 1
fi
if [[ ! "$size" =~ ^[0-9]+x[0-9]+$ ]]; then
  echo "Size must be WIDTHxHEIGHT, e.g. 1920x1080: $size" >&2
  exit 1
fi

chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
if [[ ! -x "$chrome" ]]; then
  echo "Chrome not found at $chrome; set CHROME to its path" >&2
  exit 1
fi

out="tmp/check/$slug"
rm -rf "$out"
mkdir -p "$out"
url="file://$PWD/$slug/index.html"
count="$(grep -c '<section class="slide' "$slug/index.html")"

shoot() {  # shoot <file> <slide> [extra chrome flags...]
  local file="$1" n="$2"
  shift 2
  "$chrome" --headless=new --disable-gpu --hide-scrollbars "$@" \
    --window-size="${size/x/,}" --screenshot="$file" "$url#$n" >/dev/null 2>&1
}

for ((n = 1; n <= count; n++)); do
  nn="$(printf '%02d' "$n")"
  shoot "$out/light-$nn.png" "$n"
  shoot "$out/dark-$nn.png" "$n" --blink-settings=preferredColorScheme=0
done
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$out/$slug.pdf" "$url" >/dev/null 2>&1

echo "Wrote $out/: $count slides at $size, light-NN.png and dark-NN.png, and $slug.pdf"
