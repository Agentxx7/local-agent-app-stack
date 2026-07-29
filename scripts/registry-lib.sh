#!/usr/bin/env bash

registry_required_entries() {
  local registry=$1 line key value in_entry=0
  local id= description= level= adapter= arguments= scope= fail_closed= evidence_output= owner= lifecycle=
  local check_key
  local -A seen_ids=()
  local -A seen_checks=()
  [[ -s "$registry" ]] || return 2

  registry_finalize_entry() {
    [[ -n "$id" && -n "$description" && -n "$level" && -n "$adapter" && -n "$scope" && -n "$fail_closed" && -n "$evidence_output" && -n "$owner" && -n "$lifecycle" ]] || return 2
    case "$level" in required|advisory) ;; *) return 2 ;; esac
    case "$lifecycle" in active|deprecated|retired) ;; *) return 2 ;; esac
    [[ "$level" != required || "$fail_closed" == true ]] || return 2
    [[ -z "${seen_ids[$id]+set}" ]] || return 2
    seen_ids[$id]=1
    check_key="$adapter"$'\034'"$arguments"$'\034'"$scope"
    [[ -z "${seen_checks[$check_key]+set}" ]] || return 2
    seen_checks[$check_key]=1
    [[ "$level" == required ]] && printf '%s\t%s\t%s\n' "$id" "$adapter" "$arguments"
    return 0
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%%#*}
    [[ -z "${line//[[:space:]]/}" ]] && continue
    if [[ "$line" == '[[guardrail]]' ]]; then
      if [[ "$in_entry" -eq 1 ]]; then
        registry_finalize_entry || return 2
      fi
      in_entry=1 id= description= level= adapter= arguments= scope= fail_closed= evidence_output= owner= lifecycle=
      continue
    fi
    [[ "$line" == *=* ]] || return 2
    key=${line%%=*}; key=${key//[[:space:]]/}
    value=${line#*=}; value=${value#${value%%[![:space:]]*}}; value=${value%${value##*[![:space:]]}}
    case "$value" in
      \"*\") value=${value#\"}; value=${value%\"} ;;
      true|false|[0-9]*) ;;
      *) return 2 ;;
    esac
    case "$key" in
      version) [[ "$in_entry" -eq 0 ]] || return 2 ;;
      id) id=$value ;;
      description) description=$value ;;
      level) level=$value ;;
      adapter) adapter=$value ;;
      arguments) arguments=$value ;;
      scope) scope=$value ;;
      fail_closed) fail_closed=$value ;;
      evidence_output) evidence_output=$value ;;
      owner) owner=$value ;;
      lifecycle) lifecycle=$value ;;
      *) return 2 ;;
    esac
  done < "$registry"
  [[ "$in_entry" -eq 1 ]] || return 2
  registry_finalize_entry
}
