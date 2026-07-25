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

`bash scripts/verify-operating-model.sh` checks that the required workflow, branch, TDD, evidence,
guardrail, and skill documents are non-empty and contain a small set of canonical contracts. It
requires Bash, `/usr/bin/env`, and a `grep` implementation supporting `-F` and `-q`. It verifies
documentation only: it does not run project tests, inspect their quality, protect branches,
approve work, merge, push, or update health.

## Command gate

Check classification without execution:

```text
bash scripts/command-gate.sh --check-only -- <command> <args...>
```

Execute a REVIEW command only after an operator decision:

```text
bash scripts/command-gate.sh --operator-approved <decision-id> --reason "<reason>" -- <command> <args...>
```

The gate uses Bash arrays and executes unchanged argv without dynamic evaluation. Check-only exit
codes are 0 for ALLOW, 20 for REVIEW, 30 for BLOCK, and 64 for usage errors. Unknown commands are
REVIEW. Metadata logs go to ignored `.local/command-gate.log`; arguments and reason text are not
logged. Requirements: Bash, `/usr/bin/env`, `realpath`, `date`, and standard filesystem utilities.

Run `bash scripts/tests/command-gate-test.sh` for classification, execution, exit-code, bypass, and
redaction coverage. The gate protects only commands routed through it; projects must integrate it
with their agent runner or terminal adapter. The standalone script requires approval metadata but
does not authenticate the operator or validate a decision ledger; that binding belongs in the
runner/adapter integration. Shell redirections or pipelines created outside the wrapper are also
outside its argv classifier and must be restricted by that integration.
