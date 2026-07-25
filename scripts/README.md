# Scripts

Place deterministic project checks and maintenance commands here. No runtime, build system, task
runner, or deployment tooling is selected by the skeleton.

`verify-structure.sh` checks only required baseline directories and files and deliberately permits
additional project files and subdirectories.

- `bash scripts/verify-structure.sh --template` verifies the complete published template.
- `bash scripts/verify-structure.sh --project` verifies the universal adopted-project base while
  allowing `agents/`, `database/`, and `.github/workflows/` to be absent. Guardrails, skills,
  health, quality, cards, and tests remain part of the reusable core.
- With no argument, the script uses template mode.

Requirements: Bash and `/usr/bin/env` for the script launcher. The structural checks themselves
use Bash built-ins and do not require `rg`, GNU `find`, or other validation tools.
