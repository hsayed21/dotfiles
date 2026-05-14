#!/usr/bin/env bash

# =========================
# DeepSeek Config
# =========================

SOURCE="${BASH_SOURCE[0]}"

while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"

    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

TOKEN_FILE="$SCRIPT_DIR/.deepseek-token"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Missing token file: $TOKEN_FILE"
    exit 1
fi

export ANTHROPIC_AUTH_TOKEN="$(cat "$TOKEN_FILE")"
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"

export ANTHROPIC_MODEL="deepseek-v4-flash"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"

# Terminal fixes
export TERM="xterm-256color"
export FORCE_COLOR=1

# Windows Claude fixes
export CLAUDE_CODE_USE_POWERSHELL_TOOL=0

# Launch Claude
claude --allow-dangerously-skip-permissions "$@"