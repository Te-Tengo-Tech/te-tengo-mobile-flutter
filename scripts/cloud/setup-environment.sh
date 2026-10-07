#!/usr/bin/env bash
# Prepares a Claude Code cloud session: the image does not ship Flutter.
# Runs from the SessionStart hook in .claude/settings.json and only acts in the cloud.
set -euo pipefail
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

VERSION=3.44.8   # same version the team uses locally
DIR=/opt/flutter

if [ ! -x "$DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$VERSION" https://github.com/flutter/flutter.git "$DIR"
fi
ln -sf "$DIR/bin/flutter" /usr/local/bin/flutter
ln -sf "$DIR/bin/dart" /usr/local/bin/dart
git config --global --add safe.directory "$DIR"
flutter config --no-analytics >/dev/null
cd "$CLAUDE_PROJECT_DIR" && flutter pub get
echo "Environment ready: $(flutter --version | head -1)"
