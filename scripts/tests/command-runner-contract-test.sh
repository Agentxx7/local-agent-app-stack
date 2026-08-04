#!/usr/bin/env bash
set -u

# Conformance test for guardrails/command-runner-contract.md.
#
# This suite verifies that the canonical command-runner contract document
# exists and is complete. It is deterministic, requires no network access,
# and does not require any adopted-project runner implementation to exist.
# Future projects may extend this suite with tests against their own runner
# binary or endpoint; this file only checks the template-owned contract.

root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd -P) || exit 1
cd "$root" || exit 1

contract="guardrails/command-runner-contract.md"

passed=0
failed=0

pass() {
  printf 'PASS %s\n' "$1"
  passed=$((passed + 1))
}

fail() {
  printf 'FAIL %s\n' "$1"
  failed=$((failed + 1))
}

require_file() {
  local path=$1
  if [[ -s "$path" ]]; then
    pass "file exists and is non-empty: $path"
  else
    fail "file missing or empty: $path"
  fi
}

require_text() {
  local name=$1
  local text=$2
  if [[ ! -f "$contract" ]]; then
    fail "$name (contract file absent)"
    return
  fi
  if grep -Fq -- "$text" "$contract"; then
    pass "$name"
  else
    fail "$name: missing text: $text"
  fi
}

# 1. The contract document exists.
require_file "$contract"

# 2. Every required request field is defined.
for field in argv cwd env_allowlist timeout_seconds operator_decision_id operator_reason; do
  require_text "request field documented: $field" "\`$field\`"
done

# 3. Every required result field is defined.
for field in classification category argv_digest scope_digest redaction exit_code timed_out cancelled stdout_ref stderr_ref; do
  require_text "result field documented: $field" "\`$field\`"
done

# 4. BLOCK, REVIEW and ALLOW transitions are documented.
require_text "ALLOW transition documented" "ALLOW"
require_text "REVIEW transition documented" "REVIEW"
require_text "BLOCK transition documented" "BLOCK"
require_text "state transition diagram present" "request → classify"

# 5. Scope-digest approval matching is required.
require_text "scope-digest approval matching required" "Operator approval must match the approved scope digest"

# 6. Raw shell-string execution is prohibited.
require_text "raw shell-string execution prohibited" "is never accepted as a shell command string"

# 7. Secret-safe logging is required.
require_text "secret-safe logging required" "Raw secrets and full sensitive argv are not logged"

# 8. Timeout, cancellation, cwd confinement and environment allowlisting are
#    explicitly defined.
require_text "timeout defined" "timeout_seconds"
require_text "cancellation defined" "cancelled"
require_text "cwd confinement defined" "must remain within project-approved roots"
require_text "environment allowlisting defined" "Environment variables are deny-by-default"

# 9. Enforcement is still documented as NOT_PRESENT.
require_text "enforcement documented as NOT_PRESENT" "ENFORCEMENT REMAINS NOT_PRESENT ON THE TEMPLATE MAIN BRANCH"

if [[ -f guardrails/command-safety-policy.md ]] && grep -Fq -- 'NOT_PRESENT' guardrails/command-safety-policy.md; then
  pass "command-safety-policy.md still documents NOT_PRESENT"
else
  fail "command-safety-policy.md no longer documents NOT_PRESENT"
fi

# 10. The template does not contain a language-specific runner
#     implementation. Scope the search to tracked repository paths so local,
#     untracked tooling directories cannot trip this check.
if ! command -v git >/dev/null 2>&1; then
  fail "git is required to scope the runner-implementation search to tracked files"
else
  tracked_files=$(git -C "$root" ls-files)
  runner_candidates=$(grep -E -i \
    '(^|/)(command[-_]?runner|runner[-_]?service|runner[-_]?daemon)\.(py|js|ts|go|rb|rs|java|cs|c|cpp)$' \
    <<< "$tracked_files" || true)
  if [[ -z "$runner_candidates" ]]; then
    pass "no language-specific command-runner implementation found in tracked files"
  else
    fail "language-specific runner implementation found in tracked files: $runner_candidates"
  fi
fi

# Adoption guidance: a connecting section must exist and explain the wiring.
adoption_doc="docs/adopting-the-template.md"
require_file "$adoption_doc"
if [[ -f "$adoption_doc" ]] && grep -Fq -- 'Connecting a command runner' "$adoption_doc"; then
  pass "adoption guide has a Connecting a command runner section"
else
  fail "adoption guide missing a Connecting a command runner section"
fi

# This test file itself is the conformance-test entrypoint referenced by the
# contract; confirm it is executable so it can serve that role directly.
if [[ -x "${BASH_SOURCE[0]}" ]]; then
  pass "conformance-test entrypoint is executable"
else
  fail "conformance-test entrypoint is not executable"
fi

if [[ "$failed" -ne 0 ]]; then
  printf 'FAIL command-runner-contract conformance (%s passed, %s failed)\n' "$passed" "$failed"
  exit 1
fi

printf 'PASS command-runner-contract conformance (%s passed)\n' "$passed"
