#!/bin/bash
set -e
cd "$(dirname "$0")"

# Stop if nothing changed
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to push."
  exit 0
fi

MSG="${1:-Auto update $(date '+%Y-%m-%d %H:%M:%S')}"
git add .
git commit -m "$MSG"
git push
echo "Pushed: $MSG"
