#!/bin/bash
# APK Factory Build Script
# Usage: ./build-apk.sh <repo_url> <app_slug> <package_name>

set -euo pipefail

REPO_URL=${1:?"Usage: ./build-apk.sh <repo_url> <app_slug> <package_name>"}
APP_SLUG=${2:?"App slug required"}
PACKAGE_NAME=${3:-"com.saasvala.${APP_SLUG//-/_}"}

echo "Building APK for: $APP_SLUG"
echo "   Repo: $REPO_URL"
echo "   Package: $PACKAGE_NAME"

# Clone
git clone "$REPO_URL" "build-$APP_SLUG"
cd "build-$APP_SLUG"

# Install & Build
npm install --legacy-peer-deps 2>/dev/null || npm install --force
npm run build 2>/dev/null || npx vite build 2>/dev/null || echo "Build skipped"

# Capacitor
npm install @capacitor/core @capacitor/cli @capacitor/android --legacy-peer-deps
npx cap init "$APP_SLUG" "$PACKAGE_NAME" --web-dir dist
npx cap add android
npx cap sync

# Build APK
cd android
chmod +x gradlew
./gradlew assembleDebug --no-daemon

echo "APK built for $APP_SLUG"
find . -name "*.apk" -type f
