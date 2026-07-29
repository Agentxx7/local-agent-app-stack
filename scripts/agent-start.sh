#!/usr/bin/env bash
set -u

read_only=0
project_mode=auto
for arg in "$@"; do
  case "$arg" in
    --read-only) read_only=1 ;;
    --project) project_mode=project ;;
    *) printf 'FAIL unknown option: %s\n' "$arg" >&2; exit 64 ;;
  esac
done

script_root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 1
git_root=$(git -C "$script_root" rev-parse --show-toplevel 2>/dev/null) || { printf 'FAIL repository root\n'; exit 1; }
[[ "$script_root" == "$git_root" ]] || { printf 'FAIL repository root mismatch\n'; exit 1; }
cd "$git_root" || exit 1

failed=0
for file in PROJECT.md ARCHITECTURE.md AGENTS.md; do
  [[ -s "$file" ]] || { printf 'FAIL missing or empty %s\n' "$file"; failed=1; }
done
if [[ "$project_mode" == auto ]] && ! grep -Fq 'Complete this file after creating a real project from the template.' PROJECT.md; then
  project_mode=project
fi
if [[ "$project_mode" == project ]] && grep -Eq '^- (Name|Purpose|Users|Scope):[[:space:]]*$' PROJECT.md; then
  printf 'FAIL PROJECT.md is not completed in project mode\n'
  failed=1
fi

branch=$(git branch --show-current 2>/dev/null)
[[ -n "$branch" ]] || { printf 'FAIL detached HEAD\n'; failed=1; }
status=$(git status --short)
if [[ -n "$status" ]]; then
  if [[ "$read_only" -eq 1 ]]; then
    printf 'INFO dirty worktree observed in read-only audit\n'
  else
    printf 'FAIL dirty worktree\n'
    failed=1
  fi
fi

card_id=
if [[ "$read_only" -eq 0 ]]; then
  [[ "$branch" != main ]] || { printf 'FAIL direct work on main\n'; failed=1; }
  if [[ "$branch" == work/* && -n "${branch#work/}" ]]; then
    card_id=${branch#work/}
  else
    printf 'FAIL active card branch is required\n'
    failed=1
  fi
  if [[ -n "${AGENT_CARD_ID:-}" && "$AGENT_CARD_ID" != "$card_id" ]]; then
    printf 'FAIL active card ID does not match branch\n'
    failed=1
  fi
else
  card_id=READ_ONLY
fi

[[ -x scripts/command-gate.sh ]] || { printf 'FAIL command-gate missing or not executable\n'; failed=1; }
[[ -f scripts/verify.sh ]] || { printf 'FAIL verify runner missing\n'; failed=1; }
[[ "$failed" -eq 0 ]] || exit 1

bash scripts/verify.sh || exit $?

registry_digest=$(sha256sum guardrails/registry.toml | awk '{print $1}') || exit 1
policy_registry_digest=$(sha256sum AGENTS.md guardrails/registry.toml scripts/command-gate.sh | awk '{print $1}' | sha256sum | awk '{print $1}') || exit 1
baseline=$(git rev-parse HEAD) || exit 1
session_id=$(printf '%s:%s:%s:%s' "$git_root" "$branch" "$baseline" "$(date -u +%s%N)" | sha256sum | awk '{print $1}')
required=$(bash -c 'source "$1"; registry_required_entries "$2"' _ scripts/registry-lib.sh guardrails/registry.toml | awk -F '\t' 'BEGIN{s=""}{s=s (s?",":"") $1}END{print s}') || exit 1
mkdir -p .local || exit 1
umask 077
{
  printf 'session_id=%s\n' "$session_id"
  printf 'repository_root=%s\n' "$git_root"
  printf 'baseline_commit=%s\n' "$baseline"
  printf 'branch=%s\n' "$branch"
  printf 'card_id=%s\n' "$card_id"
  printf 'registry_digest=%s\n' "$registry_digest"
  printf 'policy_registry_digest=%s\n' "$policy_registry_digest"
  printf 'startup_time=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'session_mode=%s\n' "$([[ "$read_only" -eq 1 ]] && printf read-only || printf write)"
  printf 'required_guardrails=%s\n' "$required"
} > .local/agent-session.env
printf 'PASS agent_start mode=%s branch=%s card=%s\n' "$([[ "$read_only" -eq 1 ]] && printf read-only || printf write)" "$branch" "$card_id"
