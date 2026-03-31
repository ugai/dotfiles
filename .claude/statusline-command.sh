#!/usr/bin/env bash
input=$(cat)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')
[ -z "$model" ] && model="--"

# Current working directory
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)

# Git branch
git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
if [ -n "$git_branch" ]; then
  location_str="${cwd} (${git_branch})"
else
  location_str="${cwd}"
fi

# Context window usage (pre-calculated used_percentage)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  context_str="ctx: ${used_int}%"
else
  context_str="ctx: --"
fi

# Session token total (cumulative input + output)
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
session_tokens=$((${total_in%.*} + ${total_out%.*}))

if [ "$session_tokens" -gt 0 ] 2>/dev/null; then
  if [ "$session_tokens" -ge 1000000 ]; then
    session_str=$(awk "BEGIN { printf \"%.1fM tok\", $session_tokens/1000000 }")
  elif [ "$session_tokens" -ge 1000 ]; then
    session_str=$(awk "BEGIN { printf \"%.1fk tok\", $session_tokens/1000 }")
  else
    session_str="${session_tokens} tok"
  fi
else
  session_str="--"
fi

# Rate limits (Claude.ai subscription) — optional fields
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if [ -n "$five_pct" ]; then
  five_str="5h: $(printf "%.0f" "$five_pct")%"
else
  five_str="5h: --"
fi
if [ -n "$week_pct" ]; then
  week_str="7d: $(printf "%.0f" "$week_pct")%"
else
  week_str="7d: --"
fi

printf "%s | %s | %s | %s | %s | %s" "$location_str" "$model" "$session_str" "$context_str" "$five_str" "$week_str"
