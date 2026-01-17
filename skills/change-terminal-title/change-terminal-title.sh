#!/bin/bash
# Change terminal/tmux title script
# Usage: change-terminal-title.sh "New Title"
# Works with tmux (SSH sessions) and local terminals

set -e

SCRIPT_NAME=$(basename "$0")

if [ -z "$1" ]; then
  echo "Usage: $SCRIPT_NAME <title>"
  echo "Example: $SCRIPT_NAME \"My Terminal Title\""
  exit 1
fi

TITLE="$1"

# Check if running inside tmux
if [ -n "$TMUX" ]; then
  # tmux: rename current window
  tmux rename-window "$TITLE"
  echo "tmux window title changed to: $TITLE"
else
  # Local terminal: use ANSI escape sequence
  printf '\033]0;%s\007' "$TITLE"
  echo "Terminal title changed to: $TITLE"
fi
