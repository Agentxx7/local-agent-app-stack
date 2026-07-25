#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 1
cd "$root" || exit 1

required_directories=(
  ".github/workflows"
  "agents"
  "backend"
  "cards"
  "config"
  "database/migrations"
  "docs"
  "frontend"
  "guardrails"
  "health"
  "incidents"
  "modules/module-template"
  "scripts"
  "shared"
  "skills/skill-template"
  "templates"
  "tests/unit"
  "tests/integration"
  "tests/end-to-end"
)

required_files=(
  ".github/workflows/README.md"
  ".gitignore"
  "ARCHITECTURE.md"
  "PROJECT.md"
  "README.md"
  "agents/README.md"
  "agents/agent-template.md"
  "backend/.gitkeep"
  "backend/README.md"
  "cards/README.md"
  "cards/status-report-template.md"
  "cards/task-card-template.md"
  "config/.gitkeep"
  "config/README.md"
  "database/README.md"
  "database/migrations/.gitkeep"
  "docs/README.md"
  "frontend/.gitkeep"
  "frontend/README.md"
  "guardrails/README.md"
  "guardrails/guardrail-template.md"
  "health/README.md"
  "health/health-check-template.md"
  "incidents/README.md"
  "incidents/incident-template.md"
  "modules/README.md"
  "modules/module-template/README.md"
  "scripts/README.md"
  "scripts/verify-structure.sh"
  "shared/.gitkeep"
  "shared/README.md"
  "skills/README.md"
  "skills/skill-template/SKILL.md"
  "templates/architecture-decision-template.md"
  "templates/feature-template.md"
  "templates/module-template.md"
  "templates/project-context-template.md"
  "tests/README.md"
  "tests/end-to-end/.gitkeep"
  "tests/integration/.gitkeep"
  "tests/unit/.gitkeep"
)

failed=0
for directory in "${required_directories[@]}"; do
  if [[ ! -d "$directory" ]]; then
    printf 'FAIL missing required directory: %s\n' "$directory"
    failed=1
  fi
done

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'FAIL missing required file: %s\n' "$file"
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  printf 'FAIL required skeleton structure\n'
  exit 1
fi

printf 'PASS required skeleton structure\n'
