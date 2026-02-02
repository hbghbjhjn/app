#!/usr/bin/env bash
set -euo pipefail

# Expects env var BODY to contain the full GitHub comment body.
# Patch must be between markers:
# ---PATCH---
# (unified diff)
# ---ENDPATCH---

: "${BODY:?BODY env var is required}"

PATCH_FILE="$(mktemp)"
trap 'rm -f "$PATCH_FILE"' EXIT

# Extract patch between markers
awk '
  $0 ~ /^---PATCH---$/ {inpatch=1; next}
  $0 ~ /^---ENDPATCH---$/ {inpatch=0}
  inpatch {print}
' <<< "$BODY" > "$PATCH_FILE"

if [ ! -s "$PATCH_FILE" ]; then
  echo "No patch found. Add your unified diff between ---PATCH--- and ---ENDPATCH---"
  exit 1
fi

echo "Patch preview (first 200 lines):"
sed -n '1,200p' "$PATCH_FILE"

echo "Validating patch applies cleanly..."
git apply --check "$PATCH_FILE"

echo "Applying patch..."
git apply --whitespace=fix "$PATCH_FILE"

echo "Patch applied successfully."
