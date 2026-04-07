#!/usr/bin/env bash
# PreToolUse hook: block git pushes to main or master
cmd=$(jq -r '.tool_input.command // ""')
if echo "$cmd" | grep -qE '\bgit\b.*\bpush\b.*\b(main|master)\b'; then
  echo '{"continue": false, "stopReason": "Blocked: pushing to main or master is not allowed. Push to a feature branch instead."}'
fi
