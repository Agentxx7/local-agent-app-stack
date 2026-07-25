#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 1
cd "$root" || exit 1

required_files=(
  "workflow/operator-tdd-card-loop.md"
  "workflow/two-branch-model.md"
  "quality/tdd-and-evidence-policy.md"
  "guardrails/branch-and-promotion-policy.md"
  "guardrails/test-integrity-policy.md"
  "skills/test-driven-implementation/SKILL.md"
  "skills/production-path-verification/SKILL.md"
)

failed=0
for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    printf 'FAIL missing or empty operating-model file: %s\n' "$file"
    failed=1
  fi
done

require_text() {
  file=$1
  text=$2
  if ! grep -Fq -- "$text" "$file"; then
    printf 'FAIL missing operating-model contract in %s: %s\n' "$file" "$text"
    failed=1
  fi
}

require_text README.md 'conversation-driven, operator-controlled, card-based development'
require_text README.md '## Test-driven card lifecycle'
require_text workflow/two-branch-model.md 'work/<card-id>'
require_text quality/tdd-and-evidence-policy.md 'Every code card begins with a defined failing proof where practical'
require_text quality/tdd-and-evidence-policy.md 'Tests guide implementation; evidence and the operator determine'
require_text quality/definition-of-done.md 'Promoted to main:'

if [[ "$failed" -ne 0 ]]; then
  printf 'FAIL operating-model documentation contract\n'
  exit 1
fi

printf 'PASS operating-model documentation contract\n'
