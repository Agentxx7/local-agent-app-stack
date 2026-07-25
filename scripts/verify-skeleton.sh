#!/usr/bin/env bash
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

required_files='README.md
AGENTS.md
PROJECT.md
ARCHITECTURE.md
agents/README.md
agents/agent-template.md
skills/README.md
skills/skill-template/SKILL.md
health/README.md
health/project-health.md
health/repository-health.md
health/architecture-health.md
health/dependency-health.md
health/runtime-health.md
health/process-health.md
health/state-health.md
health/test-health.md
workflow/README.md
workflow/operator-card-loop.md
workflow/handoff.md
workflow/evidence-and-status.md
guardrails/README.md
guardrails/canonical-guardrails.md
guardrails/enforcement-map.md
guardrails/rejected-policy.md
guardrails/dirty-state-policy.md
cards/task-card.md
cards/analysis-card.md
cards/review-card.md
cards/cleanup-card.md
cards/status-report.md
cards/closure-report.md
incidents/README.md
incidents/INCIDENT_REGISTER.md
incidents/incident-template.md
incidents/incident-to-guardrail.md
templates/project-context.md
templates/architecture-decision.md
templates/agent-definition.md
templates/health-check.md
frontend/.gitkeep
backend/.gitkeep
modules/.gitkeep
config/.gitkeep
database/.gitkeep
tests/.gitkeep
docs/.gitkeep
.github/workflows/.gitkeep'

while IFS= read -r file; do [[ -e "$file" ]] || { printf 'FAIL missing %s\n' "$file"; exit 1; }; done <<< "$required_files"

rg -Fq 'Conversation-driven, operator-controlled, card-based multi-agent development.' README.md
rg -Fq 'The operator chooses which agent receives the card.' README.md
rg -Fq 'No status `KLAR` is valid without relevant evidence and the operator' README.md
rg -q '^sequenceDiagram$' README.md
rg -Fq 'participant Reviewer as Valfri reviewer / Wise Man' README.md

if rg -n -i '(/home/[^/ ]+|/Users/[^/ ]+|[A-Z]:\\Users\\)' --glob '!verify-skeleton.sh' .; then printf 'FAIL private path\n'; exit 1; fi
if rg -n -i '(api[_-]?key|access[_-]?token|password|private[_-]?key)[[:space:]]*[:=][[:space:]]*[^ <{][^ ]{5,}' .; then printf 'FAIL probable secret\n'; exit 1; fi
if rg -n -i '(warhammer|lilith|chatterbox|nightstalker|v1-nightstalker-extracted)' --glob '!verify-skeleton.sh' .; then printf 'FAIL project-specific material\n'; exit 1; fi
if find . -type f -not -path './.git/*' | rg -i '\.(gguf|onnx|safetensors|wav|mp3|flac|blend|glb|gltf|zip)$'; then printf 'FAIL model or large asset\n'; exit 1; fi

printf 'PASS required structure\n'
printf 'PASS workflow locks and Mermaid sequence\n'
printf 'PASS secret, private-path, specificity, and asset scans\n'
