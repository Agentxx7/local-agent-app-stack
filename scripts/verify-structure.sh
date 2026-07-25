#!/usr/bin/env bash
set -u

usage() {
  printf 'Usage: scripts/verify-structure.sh [--template|--project]\n'
}

if [[ "$#" -gt 1 ]]; then
  printf 'FAIL expected at most one mode argument\n'
  usage
  exit 1
fi

mode=${1:---template}
case "$mode" in
  --template|--project) ;;
  *)
    printf 'FAIL unknown mode: %s\n' "$mode"
    usage
    exit 1
    ;;
esac

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit 1
cd "$root" || exit 1

required_directories=(
  "backend"
  "cards"
  "config"
  "docs"
  "frontend"
  "guardrails"
  "incidents"
  "modules/module-template"
  "scripts"
  "shared"
  "templates"
  "tests/unit"
  "tests/integration"
  "tests/end-to-end"
)

required_files=(
  ".gitignore"
  "ARCHITECTURE.md"
  "PROJECT.md"
  "README.md"
  "backend/.gitkeep"
  "backend/README.md"
  "cards/README.md"
  "cards/status-report-template.md"
  "cards/task-card-template.md"
  "config/.gitkeep"
  "config/README.md"
  "docs/README.md"
  "frontend/.gitkeep"
  "frontend/README.md"
  "guardrails/README.md"
  "guardrails/guardrail-template.md"
  "incidents/README.md"
  "incidents/incident-template.md"
  "modules/README.md"
  "modules/module-template/README.md"
  "scripts/README.md"
  "scripts/verify-structure.sh"
  "shared/.gitkeep"
  "shared/README.md"
  "templates/architecture-decision-template.md"
  "templates/feature-template.md"
  "templates/module-template.md"
  "templates/project-context-template.md"
  "tests/README.md"
  "tests/end-to-end/.gitkeep"
  "tests/integration/.gitkeep"
  "tests/unit/.gitkeep"
)

if [[ "$mode" == "--template" ]]; then
  required_directories+=(
    ".github/workflows"
    "agents"
    "database/migrations"
    "health"
    "skills/skill-template"
  )
  required_files+=(
    ".github/workflows/README.md"
    "agents/README.md"
    "agents/agent-template.md"
    "database/README.md"
    "database/migrations/.gitkeep"
    "health/README.md"
    "health/health-check-template.md"
    "skills/README.md"
    "skills/skill-template/SKILL.md"
  )
fi

failed=0
for directory in "${required_directories[@]}"; do
  if [[ ! -d "$directory" ]]; then
    printf 'FAIL missing required directory in %s mode: %s\n' "${mode#--}" "$directory"
    failed=1
  fi
done

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'FAIL missing required file in %s mode: %s\n' "${mode#--}" "$file"
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  printf 'FAIL required %s structure\n' "${mode#--}"
  exit 1
fi

printf 'PASS required %s structure\n' "${mode#--}"
