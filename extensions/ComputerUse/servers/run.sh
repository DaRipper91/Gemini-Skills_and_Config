#!/usr/bin/env bash
set -euo pipefail

EXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
SERVERS_DIR="$EXT_DIR/servers"
VENV="$SERVERS_DIR/computerusemcp"

# Respect override if provided (absolute path or command name)
CANDIDATE_PY="${PYTHON_BIN:-}"

pick_python() {
  # 1) If user provided PYTHON_BIN, use it after verifying version
  if [[ -n "$CANDIDATE_PY" ]]; then
    if "$CANDIDATE_PY" - <<'PY' >/dev/null 2>&1; then
import sys; sys.exit(0 if (sys.version_info.major, sys.version_info.minor) >= (3,10) else 1)
PY
      echo "$CANDIDATE_PY"; return 0
    else
      echo "[computer_use] ERROR: PYTHON_BIN ('$CANDIDATE_PY') is < 3.10 or invalid" >&2
      return 1
    fi
  fi

  # 2) Try common macOS/Homebrew interpreters in order
  for p in \
    /opt/homebrew/bin/python3.12 \
    /opt/homebrew/bin/python3.11 \
    /opt/homebrew/bin/python3.10 \
    python3.12 python3.11 python3.10 python3
  do
    if command -v "$p" >/dev/null 2>&1; then
      if "$p" - <<'PY' >/dev/null 2>&1; then
import sys; sys.exit(0 if (sys.version_info.major, sys.version_info.minor) >= (3,10) else 1)
PY
        echo "$p"; return 0
      fi
    fi
  done

  return 1
}

PYBIN="$(pick_python)" || {
  cat >&2 <<'ERR'
[computer_use] ERROR: Could not find Python >= 3.10.
On macOS (Homebrew):
  brew install python@3.12
Then re-run, or set PYTHON_BIN to the absolute path, e.g.:
  PYTHON_BIN=/opt/homebrew/bin/python3.12 ./run.sh
ERR
  exit 1
}

echo "[computer_use] EXT_DIR=$EXT_DIR" >&2
echo "[computer_use] SERVERS_DIR=$SERVERS_DIR" >&2
echo "[computer_use] VENV=$VENV" >&2
echo "[computer_use] PYBIN=$PYBIN ($( "$PYBIN" -V ))" >&2

# 1) Create venv if missing (with the chosen >=3.10 Python)
if [ ! -x "$VENV/bin/python3" ]; then
  echo "[computer_use] creating venv..." >&2
  "$PYBIN" -m venv "$VENV" 1>&2
  "$VENV/bin/python3" -m pip install -U pip wheel setuptools --disable-pip-version-check -q 1>&2
fi

# 2) Install deps (make sure your requirements use model-context-protocol, not 'mcp')
if [ -f "$SERVERS_DIR/requirements.txt" ]; then
  echo "[computer_use] installing Python dependencies..." >&2
  "$VENV/bin/python3" -m pip install -r "$SERVERS_DIR/requirements.txt" \
    --disable-pip-version-check --no-input -q 1>&2
else
  echo "[computer_use] WARNING: $SERVERS_DIR/requirements.txt not found; skipping." >&2
fi

# 3) Ensure Playwright Chromium is installed for THIS venv
echo "[computer_use] ensuring Chromium is installed..." >&2
if ! "$VENV/bin/playwright" install chromium 1>&2; then
  echo "[computer_use] ERROR: playwright chromium install failed" >&2
  exit 1
fi

# 4) Start MCP server (stdout must remain clean; logs go to stderr)
echo "[computer_use] starting MCP server..." >&2
exec "$VENV/bin/python3" "$SERVERS_DIR/computer_use_mcp.py" "$@"
