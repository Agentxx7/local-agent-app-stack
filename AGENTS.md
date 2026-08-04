# START HERE — mandatory agent bootstrap

## Current state on `main`

The intended agent bootstrap script is `scripts/agent-start.sh`. It existed on the historical frontier `work/AGENT_BOOTSTRAP_AND_GUARDRAIL_REGISTRY_V1` but was never merged to `main`. Therefore the published template on `main` does **not** currently provide `scripts/agent-start.sh`, `scripts/verify.sh`, `guardrails/registry.toml`, or `scripts/registry-lib.sh`.

Do not invent or rely on these missing scripts until an explicit frontier restores them.

## Verified entrypoint for this branch

The agent's first repository commands on this branch should be:

```text
bash scripts/verify-structure.sh --template
bash scripts/verify-operating-model.sh
```

Do not analyze repository contents, change files, or run project commands until these checks pass.
For an audit that must not mutate repository or product state, run the same commands and stop before any edit.

The operator must complete project adoption before assigning implementation cards. See
`docs/adopting-the-template.md` for the canonical first-project workflow.

# Agent command policy

## Operatorstyrd evidensdriven agentutveckling

VARNING — INGEN VIBE CODING

All agent-controlled terminal commands in this repository must be invoked through
`scripts/command-gate.sh`. Use check-only when classification is uncertain:

```text
bash scripts/command-gate.sh --check-only -- <command> <args...>
```

An `ALLOW` result may execute through the wrapper. A `REVIEW` result requires an explicit operator
decision ID, reason, and exact argv scope. A `BLOCK` result must not execute and must be reported.
Agents must not use direct terminal access, nested shells, command reconstruction, or another tool
to bypass the decision.

An agent may work, add, commit, and non-force push only the current `work/<card-id>` branch. It must
stop and report after that push. It must not push or merge to `main`, approve its own work, delete
`main`, delete its active work branch, or force-push. Promotion belongs to a separate authenticated
operator-controlled path, not a REVIEW override in this wrapper.

This is automatic pre-execution enforcement only when the wrapper is used. It is not global
terminal interception. An adopting project must connect its agent runner or terminal adapter to
the wrapper—and restrict alternate execution paths—for full technical enforcement. The standalone
wrapper checks that REVIEW metadata is present but cannot authenticate who supplied it; agents must
never invent or reuse an operator decision outside its recorded argv scope.

Enforcement classification on `main` today: **NOT_PRESENT**. This repository contains no runner or
terminal adapter that technically forces commands through `scripts/command-gate.sh`; agents must
invoke it themselves for every terminal command. Do not claim `ENFORCED`, `PARTIALLY_ENFORCED`, or
`DOCUMENTED_ONLY` status for this repository's command safety.

# Adoption and workflow references

- `docs/adopting-the-template.md` — canonical first-project workflow.
- `docs/first-project-specification.md` — required first specification card content.
- `docs/verification-and-guardrails.md` — verification commands and command-gate usage.
- `guardrails/command-runner-contract.md` — canonical command-runner request/result contract; see
  "Connecting a command runner" in `docs/adopting-the-template.md` for how an adopted project wires
  a runner to it.
- `workflow/operator-tdd-card-loop.md` — TDD card lifecycle.
- `workflow/two-branch-model.md` — protected `main` and `work/<card-id>` branches.
