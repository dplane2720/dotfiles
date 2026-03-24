#!/usr/bin/env bash
# Claude Code statusLine command
# Shows: directory | model | ctx bar

input=$(cat)

# --- Helper: render a progress bar ---
bar() {
  local pct=$1 width=${2:-10}
  local filled=$(( pct * width / 100 ))
  [ $filled -gt $width ] && filled=$width
  local empty=$(( width - filled ))
  local result=""
  local i
  for (( i=0; i<filled; i++ )); do result+="█"; done
  for (( i=0; i<empty;  i++ )); do result+="░"; done
  printf "%s" "$result"
}

# --- Extract fields from JSON ---
cwd=$(echo "$input"       | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"     | jq -r '.model.display_name // .model.id // "unknown"')
used_pct=$(echo "$input"  | jq -r '.context_window.used_percentage // empty')

# --- Directory: replace $HOME with ~ ---
short_dir="${cwd/#$HOME/\~}"

# --- Context window usage bar ---
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  ctx_str="ctx $(bar $used_int) ${used_int}%"
else
  ctx_str="ctx $(bar 0) -"
fi

# --- Auth type detection ---
# ANTHROPIC_API_KEY set → API Key; apiKey in settings.json → API Key; else → OAuth
auth_str="OAuth"
if [ -n "$ANTHROPIC_API_KEY" ]; then
  auth_str="API Key"
elif jq -e '.apiKey' "$HOME/.claude/settings.json" >/dev/null 2>&1; then
  auth_str="API Key"
fi

# --- Output ---
printf "%s  |  %s  |  %s  |  %s\n" \
  "$short_dir" "$model" "$ctx_str" "$auth_str"
