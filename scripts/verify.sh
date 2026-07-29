#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 2
registry="$root/guardrails/registry.toml"
# shellcheck source=registry-lib.sh
source "$root/scripts/registry-lib.sh"

entries=$(registry_required_entries "$registry") || {
  printf 'INFRASTRUCTURE_ERROR registry_parse guardrails/registry.toml\n'
  exit 2
}
[[ -n "$entries" ]] || { printf 'INFRASTRUCTURE_ERROR no_required_guardrails\n'; exit 2; }

overall=0
while IFS=$'\t' read -r id adapter arguments; do
  path="$root/$adapter"
  if [[ ! -f "$path" || ! -x "$path" ]]; then
    printf 'INFRASTRUCTURE_ERROR %s adapter=%s\n' "$id" "$adapter"
    overall=2
    continue
  fi
  argv=("$path")
  [[ -n "$arguments" ]] && argv+=("$arguments")
  "${argv[@]}"
  code=$?
  case "$code" in
    0) printf 'PASS %s\n' "$id" ;;
    20) printf 'NEEDS_OPERATOR_DECISION %s\n' "$id"; [[ "$overall" -eq 0 ]] && overall=20 ;;
    126|127) printf 'INFRASTRUCTURE_ERROR %s exit=%s\n' "$id" "$code"; overall=2 ;;
    *) printf 'FAIL %s exit=%s\n' "$id" "$code"; [[ "$overall" -ne 2 ]] && overall=1 ;;
  esac
done <<< "$entries"
exit "$overall"
