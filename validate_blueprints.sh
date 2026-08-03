#!/usr/bin/env bash
set -euo pipefail

# validate_blueprints.sh
# Simple Termux-friendly validator for Aetheria blueprint markdowns.
# Usage: ./validate_blueprints.sh [path]
# Example: ./validate_blueprints.sh .

ROOT_PATH="${1:-.}"
EXIT_CODE=0

echo "Validating Markdown blueprints under: $ROOT_PATH"

# Find markdown files (excluding README.md and manifest.yaml)
find "$ROOT_PATH" -maxdepth 2 -type f -name "*.md" ! -name README.md | while IFS= read -r FILE; do
  REL=$(realpath --relative-to="$(pwd)" "$FILE" 2>/dev/null || printf "%s" "$FILE")
  printf "\nChecking: %s\n" "$REL"

  # Read first line to detect frontmatter
  first_line=$(sed -n '1p' "$FILE" || true)
  if [ "${first_line}" != "---" ]; then
    printf "  ❌  Missing YAML frontmatter header (---) at top of file\n"
    EXIT_CODE=2
    continue
  fi

  # Extract frontmatter block (between the first and second '---')
  frontmatter=$(awk 'NR>1{ if ($0=="---") exit; print }' "$FILE" || true)

  # Helper to test if a key exists in the frontmatter (case-insensitive)
  has_key() {
    local key="$1"
    printf "%s\n" "$frontmatter" | grep -Ei "^${key}[:]" >/dev/null 2>&1
  }

  # Required keys
  missing=()
  for key in name slug version; do
    if ! has_key "$key"; then
      missing+=("$key")
    fi
  done

  # 'tags' may be a YAML list; accept `tags:` or `tags:` followed by `- item` lines
  if ! printf "%s\n" "$frontmatter" | grep -Ei "^tags[:]" >/dev/null 2>&1; then
    # Also allow a single-line comma-separated tags: tags: [a, b]
    if ! printf "%s\n" "$frontmatter" | grep -Ei "^tags[:].*\[.*\].*" >/dev/null 2>&1; then
      missing+=("tags")
    fi
  fi

  if [ ${#missing[@]} -ne 0 ]; then
    for k in "${missing[@]}"; do
      printf "  ❌  Missing required frontmatter field: %s\n" "$k"
    done
    EXIT_CODE=3
  else
    # Additional lightweight validations
    # slug: no spaces and lowercase recommended
    slug_val=$(printf "%s\n" "$frontmatter" | grep -Ei '^slug:' | sed -E 's/^[sS]lug:[[:space:]]*//I' | tr -d '"\r') || true
    if [ -n "${slug_val}" ]; then
      if printf "%s" "$slug_val" | grep -q '[[:space:]]'; then
        printf "  ⚠️  slug contains whitespace; recommend lowercase-hyphen format\n"
      fi
      if printf "%s" "$slug_val" | grep -q '[A-Z]'; then
        printf "  ⚠️  slug contains uppercase letters; recommend lowercase-hyphen format\n"
      fi
    fi

    printf "  ✅  Frontmatter present: name, slug, version, tags\n"
  fi

done

if [ "$EXIT_CODE" -ne 0 ]; then
  printf "\nValidation finished: some files failed checks (exit %d).\n" "$EXIT_CODE"
else
  printf "\nValidation finished: all checked files include required frontmatter.\n"
fi

exit $EXIT_CODE
