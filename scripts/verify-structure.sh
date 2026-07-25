#!/usr/bin/env bash
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

expected=$(mktemp)
actual=$(mktemp)
trap 'rm -f "$expected" "$actual"' EXIT

cat > "$expected" <<'FILES'
.github/workflows/README.md
.gitignore
ARCHITECTURE.md
PROJECT.md
README.md
agents/README.md
agents/agent-template.md
backend/.gitkeep
backend/README.md
cards/README.md
cards/status-report-template.md
cards/task-card-template.md
config/.gitkeep
config/README.md
database/README.md
database/migrations/.gitkeep
docs/README.md
frontend/.gitkeep
frontend/README.md
guardrails/README.md
guardrails/guardrail-template.md
health/README.md
health/health-check-template.md
incidents/README.md
incidents/incident-template.md
modules/README.md
modules/module-template/README.md
scripts/README.md
scripts/verify-structure.sh
shared/.gitkeep
shared/README.md
skills/README.md
skills/skill-template/SKILL.md
templates/architecture-decision-template.md
templates/feature-template.md
templates/module-template.md
templates/project-context-template.md
tests/README.md
tests/end-to-end/.gitkeep
tests/integration/.gitkeep
tests/unit/.gitkeep
FILES

find . -type f -not -path './.git/*' -printf '%P\n' | LC_ALL=C sort > "$actual"
LC_ALL=C sort -o "$expected" "$expected"
if ! cmp -s "$expected" "$actual"; then
  printf 'FAIL file structure differs\n'
  diff -u "$expected" "$actual" || true
  exit 1
fi

rg -Fq 'A reusable, technology-neutral application project skeleton.' README.md
rg -Fq 'The repository contains structure and templates only.' README.md
rg -q '^flowchart TD$' README.md
rg -Fq 'P --> I[Incidents]' README.md
rg -Fq 'Agents, skills, and health checks are optional project areas.' README.md

if rg -n -i '(nightstalker|wise man|conversation-driven|operator-controlled|working-method template|v1-nightstalker-extracted)' --glob '!verify-structure.sh' .; then
  printf 'FAIL obsolete direction remains\n'; exit 1
fi
if rg -n -i '(/home/[^/ ]+|/Users/[^/ ]+|[A-Z]:\\Users\\)' --glob '!verify-structure.sh' .; then
  printf 'FAIL private path\n'; exit 1
fi
if rg -n -i '(api[_-]?key|access[_-]?token|password|private[_-]?key)[[:space:]]*[:=][[:space:]]*[^ <{][^ ]{5,}' .; then
  printf 'FAIL probable secret\n'; exit 1
fi
if find . -type f -not -path './.git/*' | rg -i '\.(gguf|onnx|safetensors|wav|mp3|flac|blend|glb|gltf|zip)$'; then
  printf 'FAIL model or large asset\n'; exit 1
fi

printf 'PASS exact standard skeleton structure\n'
printf 'PASS neutral README and repository diagram\n'
printf 'PASS obsolete-direction, secret, path, and asset scans\n'
