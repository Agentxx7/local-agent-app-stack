#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 1
cd "$root" || exit 1

required_files=(
  "README.md"
  "AGENTS.md"
  "guardrails/registry.toml"
  "cards/status-report-template.md"
  "cards/task-card-template.md"
  "workflow/README.md"
  "workflow/operator-tdd-card-loop.md"
  "workflow/two-branch-model.md"
  "quality/definition-of-done.md"
  "quality/quality-gates.md"
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
  if [[ ! -f "$file" ]]; then
    return
  fi
  if ! grep -Fq -- "$text" "$file"; then
    printf 'FAIL missing operating-model contract in %s: %s\n' "$file" "$text"
    failed=1
  fi
}

reject_pattern() {
  pattern=$1
  description=$2
  if grep -Eiq -- "$pattern" <<< "$contract_text"; then
    printf 'FAIL operating-model contract explicitly allows: %s\n' "$description"
    failed=1
  fi
}

require_text README.md 'conversation-driven, operator-controlled, card-based development'
require_text README.md 'README instructions alone are documentation, not enforcement.'
require_text AGENTS.md "bash scripts/agent-start.sh"
require_text README.md '## Test-driven card lifecycle'
require_text README.md 'The agent reports evidence but does not approve its own work.'
require_text workflow/README.md 'one short-lived branch per active card'
require_text workflow/two-branch-model.md 'Receives no direct implementation work.'
require_text workflow/two-branch-model.md 'Owned by exactly one card.'
require_text workflow/operator-tdd-card-loop.md 'The operator decides whether the evidence supports promotion.'
require_text quality/tdd-and-evidence-policy.md 'Every code card begins with a defined failing proof where practical'
require_text quality/tdd-and-evidence-policy.md 'Tests guide implementation; evidence and the operator determine'
require_text quality/definition-of-done.md 'Promoted to main:'
require_text quality/quality-gates.md 'branch isolation and operator-controlled promotion are mandatory gates'
require_text quality/quality-gates.md 'must not be marked `NOT APPLICABLE` for code or product changes.'
absolute_override='No override may allow direct implementation on main, multiple cards on one work branch, mixed or foreign scope, agent self-approval, promotion without an explicit operator decision, unexplained failing tests, or promotion without evidence from the real affected path.'
require_text guardrails/branch-and-promotion-policy.md "$absolute_override"
require_text cards/task-card-template.md 'Failing proof (RED) or justified alternative:'
require_text cards/task-card-template.md 'Verification, including real affected path:'
require_text cards/task-card-template.md 'Stop conditions:'
require_text cards/status-report-template.md 'Operator acceptance: Pending / recorded decision'
require_text cards/status-report-template.md 'Promotion to main: Not performed / commit'
require_text cards/status-report-template.md 'Post-promotion main verification:'

contract_files=(README.md workflow/*.md guardrails/*.md quality/*.md cards/*.md skills/*/SKILL.md)
contract_text=
for file in "${contract_files[@]}"; do
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "- Operator override: $absolute_override" ]]; then
      continue
    fi
    if [[ -z "$line" ]]; then
      contract_text+=$'\n'
    else
      contract_text+=" $line"
    fi
  done < "$file"
  contract_text+=$'\n'
done
reject_pattern '(direct implementation|implementation work).*(on|to)[[:space:]]+`?main`?.*(is[[:space:]]+)?(allowed|permitted)' \
  'direct implementation on main'
reject_pattern '(allow|permit)(s|ted)?.*(direct implementation|implementation work).*`?main`?' \
  'direct implementation on main'
reject_pattern '(agent|work agent).*(may|can|is allowed to).*(self[- ]approve|approve (its|their) own work)' \
  'agent self-approval'
reject_pattern "agent('?s)? self-approval.*(allowed|permitted)" \
  'agent self-approval'
reject_pattern '(allow|permit)(s|ted)?.*promotion without (an )?(explicit )?operator (decision|approval)' \
  'promotion without an operator decision'
reject_pattern 'promotion without (an )?(explicit )?operator (decision|approval).*(is[[:space:]]+)?(allowed|permitted)' \
  'promotion without an operator decision'
reject_pattern '(multiple|more than one) (cards?|work cards?).*(one|same) work branch.*(allowed|permitted)' \
  'multiple cards on one work branch'
reject_pattern '(allow|permit)(s|ted)?.*(multiple|more than one) (cards?|work cards?).*(one|same) work branch' \
  'multiple cards on one work branch'
reject_pattern '(mixed|foreign|unrelated) scope.*(allowed|permitted)' \
  'mixed or foreign scope'
reject_pattern '(allow|permit)(s|ted)?.*(mixed|foreign|unrelated) scope' \
  'mixed or foreign scope'
reject_pattern 'reasoned exception' \
  'a broad reasoned exception'

if [[ "$failed" -ne 0 ]]; then
  printf 'FAIL operating-model documentation contract\n'
  exit 1
fi

printf 'PASS operating-model documentation contract\n'
