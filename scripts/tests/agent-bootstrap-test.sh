#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd -P) || exit 1
test_root=$(mktemp -d "${TMPDIR:-/tmp}/agent-bootstrap-test.XXXXXX") || exit 1
trap 'find "$test_root" -depth -delete' EXIT
passed=0 failed=0

record() {
  local name=$1 expected=$2 actual=$3
  if [[ "$expected" == "$actual" ]]; then
    printf 'PASS %s\n' "$name"; passed=$((passed + 1))
  else
    printf 'FAIL %s expected=%s actual=%s\n' "$name" "$expected" "$actual"
    failed=$((failed + 1))
  fi
}

make_repo() {
  local name=$1 branch=${2:-work/TEST-CARD} dir
  dir="$test_root/$name"
  mkdir -p "$dir"
  cp -R "$root/." "$dir"
  find "$dir/.git" "$dir/.local" -depth -delete 2>/dev/null || true
  chmod +x "$dir/scripts/command-gate.sh" "$dir/scripts/agent-start.sh" "$dir/scripts/verify.sh" \
    "$dir/scripts/verify-structure.sh" "$dir/scripts/verify-operating-model.sh"
  git -C "$dir" init -q -b main
  git -C "$dir" config user.name 'Bootstrap Fixture'
  git -C "$dir" config user.email 'bootstrap@example.invalid'
  git -C "$dir" add .
  git -C "$dir" commit -qm baseline
  [[ "$branch" == main ]] || git -C "$dir" switch -qc "$branch"
  printf '%s' "$dir"
}

missing=$(make_repo missing-script)
find "$missing/scripts/agent-start.sh" -delete
(cd "$missing" && bash scripts/agent-start.sh) >/dev/null 2>&1; record agent-start-missing 127 $?

on_main=$(make_repo on-main main)
(cd "$on_main" && bash scripts/agent-start.sh) >/dev/null 2>&1; record work-on-main 1 $?

no_card=$(make_repo no-card topic)
(cd "$no_card" && bash scripts/agent-start.sh) >/dev/null 2>&1; record missing-active-card 1 $?

missing_adapter=$(make_repo missing-adapter)
sed -i 's#scripts/verify-structure.sh#scripts/missing-required-adapter.sh#' "$missing_adapter/guardrails/registry.toml"
(cd "$missing_adapter" && bash scripts/verify.sh) >/dev/null 2>&1; record missing-required-adapter 2 $?

broken=$(make_repo broken-registry)
printf '\nthis is not toml\n' >> "$broken/guardrails/registry.toml"
(cd "$broken" && bash scripts/verify.sh) >/dev/null 2>&1; record broken-registry 2 $?

duplicate_id=$(make_repo duplicate-id)
printf '%s\n' \
  '' '[[guardrail]]' 'id = "template_structure"' 'description = "Duplicate identifier."' \
  'level = "required"' 'adapter = "scripts/verify-operating-model.sh"' 'arguments = "duplicate"' \
  'scope = "duplicate-scope"' 'fail_closed = true' 'evidence_output = "stdout"' \
  'owner = "repository-operator"' 'lifecycle = "active"' >> "$duplicate_id/guardrails/registry.toml"
(cd "$duplicate_id" && bash scripts/verify.sh) >/dev/null 2>&1; record duplicate-guardrail-id 2 $?

duplicate_check=$(make_repo duplicate-check)
printf '%s\n' \
  '' '[[guardrail]]' 'id = "duplicate_check"' 'description = "Duplicate adapter check."' \
  'level = "required"' 'adapter = "scripts/verify-structure.sh"' 'arguments = "--template"' \
  'scope = "repository"' 'fail_closed = true' 'evidence_output = "stdout"' \
  'owner = "repository-operator"' 'lifecycle = "active"' >> "$duplicate_check/guardrails/registry.toml"
(cd "$duplicate_check" && bash scripts/verify.sh) >/dev/null 2>&1; record duplicate-adapter-arguments-scope 2 $?

missing_id=$(make_repo missing-id)
sed -i '0,/^id = /{/^id = /d;}' "$missing_id/guardrails/registry.toml"
(cd "$missing_id" && bash scripts/verify.sh) >/dev/null 2>&1; record missing-required-id 2 $?

unknown_level=$(make_repo unknown-level)
sed -i '0,/level = "required"/s//level = "unknown"/' "$unknown_level/guardrails/registry.toml"
(cd "$unknown_level" && bash scripts/verify.sh) >/dev/null 2>&1; record unknown-level 2 $?

unknown_lifecycle=$(make_repo unknown-lifecycle)
sed -i '0,/lifecycle = "active"/s//lifecycle = "unknown"/' "$unknown_lifecycle/guardrails/registry.toml"
(cd "$unknown_lifecycle" && bash scripts/verify.sh) >/dev/null 2>&1; record unknown-lifecycle 2 $?

missing_required_adapter=$(make_repo missing-required-adapter-field)
sed -i '0,/^adapter = /{/^adapter = /d;}' "$missing_required_adapter/guardrails/registry.toml"
(cd "$missing_required_adapter" && bash scripts/verify.sh) >/dev/null 2>&1; record required-without-adapter 2 $?

non_executable=$(make_repo non-executable-adapter)
chmod -x "$non_executable/scripts/verify-structure.sh"
(cd "$non_executable" && bash scripts/verify.sh) >/dev/null 2>&1; record required-non-executable-adapter 2 $?

advisory=$(make_repo advisory-entry)
sed -i '0,/level = "required"/s//level = "advisory"/' "$advisory/guardrails/registry.toml"
(cd "$advisory" && bash scripts/verify.sh) >/dev/null 2>&1; record advisory-parsed-not-required 0 $?

distinct_reuse=$(make_repo distinct-adapter-reuse)
printf '%s\n' \
  '' '[[guardrail]]' 'id = "project_structure_advisory"' 'description = "Distinct adapter reuse."' \
  'level = "advisory"' 'adapter = "scripts/verify-structure.sh"' 'arguments = "--project"' \
  'scope = "adopted-project"' 'fail_closed = false' 'evidence_output = "stdout"' \
  'owner = "repository-operator"' 'lifecycle = "active"' >> "$distinct_reuse/guardrails/registry.toml"
(cd "$distinct_reuse" && bash scripts/verify.sh) >/dev/null 2>&1; record adapter-reuse-with-distinct-arguments-scope 0 $?

stale=$(make_repo stale-session)
mkdir -p "$stale/.local"
digest=$(sha256sum "$stale/guardrails/registry.toml" | awk '{print $1}')
baseline=$(git -C "$stale" rev-parse HEAD)
{
  printf 'repository_root=%s\n' "$stale"
  printf 'baseline_commit=%s\n' "$baseline"
  printf 'branch=work/OTHER-CARD\ncard_id=OTHER-CARD\nregistry_digest=%s\nsession_mode=write\n' "$digest"
} > "$stale/.local/agent-session.env"
(cd "$stale" && bash scripts/command-gate.sh -- git status) >/dev/null 2>&1; record stale-session-receipt 30 $?

changed=$(make_repo changed-registry)
(cd "$changed" && bash scripts/agent-start.sh) >/dev/null 2>&1 || { printf 'FAIL changed-registry setup\n'; failed=$((failed + 1)); }
printf '\n# changed after startup\n' >> "$changed/guardrails/registry.toml"
(cd "$changed" && bash scripts/command-gate.sh -- git status) >/dev/null 2>&1; record registry-changed-after-startup 30 $?

direct=$(make_repo direct-without-session)
(cd "$direct" && bash scripts/command-gate.sh -- git status) >/dev/null 2>&1; record direct-gate-without-session 30 $?

readonly=$(make_repo read-only main)
(cd "$readonly" && bash scripts/agent-start.sh --read-only) >/dev/null 2>&1 || { printf 'FAIL read-only setup\n'; failed=$((failed + 1)); }
(cd "$readonly" && bash scripts/command-gate.sh -- touch forbidden) >/dev/null 2>&1; record read-only-write-attempt 30 $?

correct=$(make_repo correct-startup)
(cd "$correct" && bash scripts/agent-start.sh) >/dev/null 2>&1; start_code=$?
(cd "$correct" && bash scripts/command-gate.sh -- git status --short) >/dev/null 2>&1; gate_code=$?
record correct-startup 0 "$start_code"
record correct-gated-command 0 "$gate_code"

printf 'RESULT passed=%s failed=%s\n' "$passed" "$failed"
[[ "$failed" -eq 0 ]]
