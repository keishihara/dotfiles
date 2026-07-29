#!/usr/bin/env bash
# Claude Code statusline: dir / git branch / model / context usage / rate limits
set -uo pipefail

input=$(cat)

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0')
ctx_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 0')
used_tok=$(printf '%s' "$input" | jq -r '
  (.context_window.current_usage // {}) as $u
  | (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0))')
h5=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
d7=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')

short_dir="${dir/#$HOME/~}"
short_dir="${short_dir##*/}"

branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

# 10-cell bar for context usage
pct_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
filled=$(( pct_int / 10 ))
(( filled > 10 )) && filled=10
bar=""
for ((i = 0; i < 10; i++)); do
  if (( i < filled )); then bar+="█"; else bar+="░"; fi
done

# color by pressure: green < 50 < yellow < 80 < red
if   (( pct_int >= 80 )); then c=$'\033[31m'
elif (( pct_int >= 50 )); then c=$'\033[33m'
else                          c=$'\033[32m'
fi
r=$'\033[0m'; dim=$'\033[2m'

fmt_k() { awk -v n="$1" 'BEGIN{ if (n >= 1000) printf "%.0fk", n/1000; else printf "%d", n }'; }

out="${dim}${short_dir}${r}"
[[ -n "$branch" ]] && out+=" ${dim}(${branch})${r}"
[[ -n "$model"  ]] && out+=" ${dim}|${r} ${model}"
out+=" ${dim}|${r} ${c}${bar} ${pct_int}%${r} ${dim}$(fmt_k "$used_tok")/$(fmt_k "$ctx_size")${r}"
[[ -n "$h5" ]] && out+=" ${dim}| 5h $(printf '%.0f' "$h5")%${r}"
[[ -n "$d7" ]] && out+=" ${dim}/ 7d $(printf '%.0f' "$d7")%${r}"
out+=" ${dim}| \$$(printf '%.2f' "$cost")${r}"

printf '%s' "$out"
