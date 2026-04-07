#!/usr/bin/env bash
# PreToolUse hook: block git pushes to main or master and redirect to current branch
cmd=$(jq -r '.tool_input.command // ""')
if echo "$cmd" | grep -qE '\bgit\b.*\bpush\b.*\b(main|master)\b'; then
  current_branch=$(git branch --show-current 2>/dev/null)
  if [ -n "$current_branch" ] && [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
    msg="Blocked: do not push to main or master. You are already on branch '$current_branch' — push there instead: git push -u origin $current_branch"
  else
    msg="Blocked: do not push to main or master. Create a feature branch first: git checkout -b <branch-name>, then push to that."
  fi
  printf '{"continue": false, "stopReason": "%s"}' "$msg"
fi
