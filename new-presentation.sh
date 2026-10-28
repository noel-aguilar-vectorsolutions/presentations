#!/usr/bin/env bash
# Scaffold a new presentation from _template/.
# Usage: ./new-presentation.sh <slug> ["Title"]
set -euo pipefail

cd "$(dirname "$0")"

slug="${1:-}"
if [[ -z "$slug" ]]; then
  echo "Usage: $0 <slug> [\"Title\"]" >&2
  exit 1
fi
if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Slug must be kebab-case (lowercase letters, digits, hyphens): $slug" >&2
  exit 1
fi
if [[ -e "$slug" ]]; then
  echo "Already exists: $slug" >&2
  exit 1
fi

title="${2:-$slug}"
date="$(date +%Y-%m-%d)"

cp -R _template "$slug"

# Escape characters that are special in the sed replacement.
esc_title="$(printf '%s' "$title" | sed -e 's/[\/&|]/\\&/g')"
for f in "$slug/index.html" "$slug/README.md"; do
  sed -i '' -e "s|{{TITLE}}|$esc_title|g" -e "s|{{DATE}}|$date|g" "$f"
done

echo "Created $slug/"
echo "  - edit $slug/index.html, then run ./export-markdown.py $slug"
echo "  - record sources in $slug/README.md"
echo "  - add a row to the Index table in README.md"
