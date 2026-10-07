#!/usr/bin/env bash
# Prepara una sesión de Claude Code en la nube: la imagen no trae Flutter.
# Se ejecuta desde el hook SessionStart de .claude/settings.json y solo actúa en la nube.
set -euo pipefail
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

VERSION=3.44.8   # la misma versión que usa el equipo en local
DIR=/opt/flutter

if [ ! -x "$DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$VERSION" https://github.com/flutter/flutter.git "$DIR"
fi
ln -sf "$DIR/bin/flutter" /usr/local/bin/flutter
ln -sf "$DIR/bin/dart" /usr/local/bin/dart
git config --global --add safe.directory "$DIR"
flutter config --no-analytics >/dev/null
cd "$CLAUDE_PROJECT_DIR" && flutter pub get
echo "Entorno listo: $(flutter --version | head -1)"
