#!/bin/sh
set -e

# Determine command to run based on AGENT env (set at build time) or detect installed binary
if [ -n "$AGENT" ]; then
  case "$AGENT" in
    codex)    CMD="codex"    ;;
    gemini)   CMD="gemini"   ;;
	  opencode) CMD="opencode" ;;
    claude)   CMD="claude"   ;;
    *) echo "Unknown AGENT: $AGENT" >&2; exit 1 ;;
  esac
else
  if command -v codex >/dev/null 2>&1; then
    CMD="codex"
  elif command -v gemini >/dev/null 2>&1; then
    CMD="gemini"
  elif command -v opencode >/dev/null 2>&1; then
	  CMD="opencode"
  elif command -v claude >/dev/null 2>&1; then
	  CMD="claude"
  else
    echo "No agent command found (codex or gemini)" >&2
    exit 1
  fi
fi

# If first argument is 'shell', start an interactive shell instead of running the agent
if [ "$1" = "shell" ]; then
  # consume the 'shell' arg
  shift
  if [ "$#" -gt 0 ]; then
    # run provided command(s) in a shell
    if command -v bash >/dev/null 2>&1; then
      exec bash -lc "$*"
    else
      exec sh -lc "$*"
    fi
  else
    # start an interactive shell
    if command -v bash >/dev/null 2>&1; then
      exec bash
    else
      exec sh
    fi
  fi
fi

exec "$CMD" "$@"
