#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Vercel build script for TreeSyt Flutter web
# Installs Flutter stable, builds the web target, and outputs to build/web
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FLUTTER_CHANNEL="stable"
FLUTTER_DIR="$HOME/.flutter"

echo "▶  Setting up Flutter ($FLUTTER_CHANNEL)..."

# Use a cached clone if available (Vercel caches $HOME between builds)
if [ ! -d "$FLUTTER_DIR/.git" ]; then
  git clone --depth 1 --branch "$FLUTTER_CHANNEL" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  echo "   Flutter directory found — pulling latest $FLUTTER_CHANNEL..."
  git -C "$FLUTTER_DIR" pull --ff-only
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "▶  Flutter version:"
flutter --version --machine || flutter --version

echo "▶  Enabling web..."
flutter config --no-analytics --enable-web

echo "▶  Fetching dependencies..."
flutter pub get

echo "▶  Building web (release, CanvasKit renderer)..."
flutter build web --release --web-renderer canvaskit

echo "✓  Build complete — output in build/web"
