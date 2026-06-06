#!/usr/bin/env bash
# SessionStart hook — make a fresh ARS checkout build-ready in Claude-on-web.
#
# The repo is cloned fresh for every web session, so two gitignored-but-needed
# pieces have to be (re)created here:
#   1. .env  — gitignored, yet declared as a pubspec asset, so `flutter build`
#              fails without it. Seed it from the committed .env.example.
#   2. Flutter package deps — resolve them if the SDK is on PATH.
#
# Best-effort and idempotent: it never fails or blocks the session (always
# exits 0). Runs only in the remote (web) environment.
set -uo pipefail

# Only act in Claude-on-web; local CLI users manage their own setup.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# 1) Seed .env from the template if it's missing.
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env && echo "session-start: created .env from .env.example"
fi

# 2) Resolve Flutter deps when the SDK is available; skip cleanly otherwise.
if command -v flutter >/dev/null 2>&1; then
  echo "session-start: flutter pub get"
  flutter pub get || echo "session-start: 'flutter pub get' failed (continuing)"
else
  echo "session-start: flutter not on PATH — skipping pub get"
fi

exit 0
