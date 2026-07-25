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
  "health"
  "incidents"
  "modules/module-template"
  "quality"
  "scripts"
  "shared"
  "skills"
  "skills/architecture-review"
  "skills/cleanup-and-closure"
  "skills/code-review"
  "skills/dependency-review"
  "skills/implementation"
  "skills/incident-analysis"
  "skills/problem-analysis"
  "skills/repository-audit"
  "skills/security-review"
  "skills/skill-template"
  "skills/task-card-authoring"
  "skills/testing-and-verification"
  "templates"
  "tests"
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
  "guardrails/dependency-policy.md"
  "guardrails/destructive-command-policy.md"
  "guardrails/dirty-worktree-policy.md"
  "guardrails/enforcement-map.md"
  "guardrails/evidence-and-status-policy.md"
  "guardrails/incident-to-guardrail.md"
  "guardrails/process-lifecycle-policy.md"
  "guardrails/rejected-material-policy.md"
  "guardrails/scope-and-change-control.md"
  "guardrails/secrets-and-sensitive-data.md"
  "guardrails/source-of-truth-policy.md"
  "guardrails/testing-and-production-link.md"
  "health/README.md"
  "health/architecture-health.md"
  "health/build-health.md"
  "health/dependency-health.md"
  "health/health-report-template.md"
  "health/process-health.md"
  "health/project-health.md"
  "health/repository-health.md"
  "health/runtime-health.md"
  "health/security-health.md"
  "health/state-health.md"
  "health/test-health.md"
  "incidents/README.md"
  "incidents/incident-template.md"
  "modules/README.md"
  "modules/module-template/README.md"
  "quality/README.md"
  "quality/definition-of-done.md"
  "quality/quality-gates.md"
  "quality/release-readiness-template.md"
  "quality/review-checklist.md"
  "quality/test-strategy-template.md"
  "quality/verification-levels.md"
  "scripts/README.md"
  "scripts/verify-structure.sh"
  "shared/.gitkeep"
  "shared/README.md"
  "skills/README.md"
  "skills/architecture-review/SKILL.md"
  "skills/cleanup-and-closure/SKILL.md"
  "skills/code-review/SKILL.md"
  "skills/dependency-review/SKILL.md"
  "skills/implementation/SKILL.md"
  "skills/incident-analysis/SKILL.md"
  "skills/problem-analysis/SKILL.md"
  "skills/repository-audit/SKILL.md"
  "skills/security-review/SKILL.md"
  "skills/skill-template/SKILL.md"
  "skills/task-card-authoring/SKILL.md"
  "skills/testing-and-verification/SKILL.md"
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
  )
  required_files+=(
    ".github/workflows/README.md"
    "agents/README.md"
    "agents/agent-template.md"
    "database/README.md"
    "database/migrations/.gitkeep"
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
