#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# DSS Lets — change the Android app ID from com.example.dss_lets to com.dsslets.app
# Run from the project root ON YOUR MAC (the android/ folder lives there):
#     git pull
#     bash scripts/change_app_id.sh
#
# Changes:
#   1. android/app/build.gradle   → applicationId + namespace = com.dsslets.app
#   2. AndroidManifest.xml        → package attr if present (modern templates omit it)
#   3. MainActivity.kt            → package line + file moved to com/dsslets/app/
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

OLD="com.example.dss_lets"
NEW="com.dsslets.app"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -d android ]; then
  echo "ERROR: android/ not found at $ROOT"
  echo "Run this from the project root on the Mac that has the android/ platform folder."
  exit 1
fi

echo "=== Before ==="
if grep -rn "$OLD" android/ 2>/dev/null | grep -v Binary; then
  :
else
  echo "(no com.example.dss_lets matches — already changed?)"
fi

# 1. build.gradle or build.gradle.kts — applicationId + namespace
#    (newer Flutter templates use the Kotlin DSL file .kts; classic uses .gradle)
GRADLE_FILE=""
if [ -f "android/app/build.gradle" ]; then
  GRADLE_FILE="android/app/build.gradle"
elif [ -f "android/app/build.gradle.kts" ]; then
  GRADLE_FILE="android/app/build.gradle.kts"
else
  echo "ERROR: no android/app/build.gradle or build.gradle.kts found"
  exit 1
fi
echo "Editing $GRADLE_FILE"
sed -i '' "s/$OLD/$NEW/g" "$GRADLE_FILE"

# 2. AndroidManifest.xml — package attribute, if present
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  sed -i '' "s/$OLD/$NEW/g" "$MANIFEST"
fi

# 3. MainActivity.kt — move to the new package dir and rewrite the package line
KOTLIN_DIR="android/app/src/main/kotlin"
OLD_PKG_DIR="$KOTLIN_DIR/com/example/dss_lets"
NEW_PKG_DIR="$KOTLIN_DIR/com/dsslets/app"
if [ -d "$OLD_PKG_DIR" ]; then
  mkdir -p "$NEW_PKG_DIR"
  if git ls-files --error-unmatch "$OLD_PKG_DIR/MainActivity.kt" >/dev/null 2>&1; then
    git mv "$OLD_PKG_DIR/MainActivity.kt" "$NEW_PKG_DIR/MainActivity.kt"
  else
    mv "$OLD_PKG_DIR/MainActivity.kt" "$NEW_PKG_DIR/MainActivity.kt"
  fi
  sed -i '' "s/^package com\.example\.dss_lets;/package com.dsslets.app;/" "$NEW_PKG_DIR/MainActivity.kt"
  rmdir "$OLD_PKG_DIR" "$KOTLIN_DIR/com/example" 2>/dev/null || true
fi

echo "=== After ==="
grep -rn "$NEW" "$GRADLE_FILE" "$MANIFEST" 2>/dev/null || true
if [ -f "$NEW_PKG_DIR/MainActivity.kt" ]; then
  grep -n "^package" "$NEW_PKG_DIR/MainActivity.kt"
fi

echo ""
echo "DONE ✅"
echo "Next steps before building for the store:"
echo "  1. Firebase console → Project settings → Add app → Android (package com.dsslets.app)"
echo "     → download the new google-services.json → replace android/app/google-services.json"
echo "  2. flutter pub get"
echo "  3. flutter build appbundle --release"
