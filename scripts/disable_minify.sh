#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# DSS Lets — Disable R8/minification for the release build.
# Fixes "app flashes then closes on launch" when a release build crashes at
# startup (R8 stripping a class a plugin needs at runtime is a known cause).
#
# Run from the project root ON YOUR MAC (android/ lives there):
#     git pull
#     bash scripts/disable_minify.sh
#     flutter build appbundle --release
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

GRADLE_FILE=""
if [ -f "android/app/build.gradle.kts" ]; then
  GRADLE_FILE="android/app/build.gradle.kts"
elif [ -f "android/app/build.gradle" ]; then
  GRADLE_FILE="android/app/build.gradle"
else
  echo "ERROR: android/app/build.gradle(.kts) not found. Run from the project root on the Mac."
  exit 1
fi
echo "Editing $GRADLE_FILE"

python3 - "$GRADLE_FILE" <<'PYEOF'
import re, sys
path = sys.argv[1]
s = open(path).read()
orig = s

pat = re.compile(r'(buildTypes\s*\{\s*release\s*\{)(.*?)(\n\s*\})', re.S)

def repl(m):
    head, body, tail = m.group(1), m.group(2), m.group(3)
    # Flip any existing true -> false, drop false-leaves as-is
    body = re.sub(r'\bisMinifyEnabled\s*=\s*true', 'isMinifyEnabled = false', body)
    body = re.sub(r'\bisShrinkResources\s*=\s*true', 'isShrinkResources = false', body)
    if 'isMinifyEnabled' not in body:
        body += '\n            isMinifyEnabled = false'
    if 'isShrinkResources' not in body:
        body += '\n            isShrinkResources = false'
    return head + body + tail

new = pat.sub(repl, s)
if new == orig:
    print("No buildTypes/release block matched — nothing changed. Check the file.")
    sys.exit(1)
open(path, 'w').write(new)
print("Done: release buildType now has isMinifyEnabled = false, isShrinkResources = false")
PYEOF

echo ""
echo "=== release block now reads ==="
sed -n '/buildTypes {/,/^    }/p' "$GRADLE_FILE"
echo ""
echo "NEXT: flutter build appbundle --release"
