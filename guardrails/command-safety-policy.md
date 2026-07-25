# Command safety policy

- Rule: Agent-controlled terminal commands pass through `scripts/command-gate.sh` before execution
  and receive exactly one decision: `ALLOW`, `REVIEW`, or `BLOCK`.
- Purpose: Stop known destructive commands and require explicit operator evidence for risky or
  ambiguous commands before they reach a shell or executable.
- Applies when: An agent proposes or runs a terminal command in an adopted project.
- Prohibited behaviour: Bypassing the wrapper, splitting a destructive operation to evade
  classification, using nested shell execution, fabricating approval, or executing REVIEW/BLOCK
  results outside their decision. A work agent must not use the wrapper to push or merge to `main`
  or to delete `main` or its active work branch.
- Required evidence: Original argv, classification, exit code, card scope, and—for REVIEW—the
  decision ID, reason, exact command scope, and operator record.
- Enforcement type: AUTOMATED CHECK when the wrapper is used. Direct terminal access is not
  intercepted by this template.
- Operator override: REVIEW may execute only when the invocation includes a decision ID and reason;
  the command after `--` is its exact execution scope and is passed unchanged. BLOCK has no
  ordinary override; stop and report instead.
- Remaining limitations: Full enforcement requires the project's agent runner or terminal adapter
  to invoke the wrapper exclusively. The standalone wrapper checks approval metadata presence but
  cannot authenticate the operator or validate an external decision record. Pattern classification
  cannot infer every command's effects, and shell redirections or pipelines applied outside the
  wrapper are not visible as argv. Runner integration must pass structured argv and restrict those
  alternate paths.

## Decisions and exit codes

| Decision | Meaning | Check-only exit |
|---|---|---:|
| `ALLOW` | Known low-risk command; may execute outside check-only mode. | 0 |
| `REVIEW` | Risky, unknown, or ambiguous; execution requires operator approval metadata. | 20 |
| `BLOCK` | Known destructive or bypass command; never executes through the wrapper. | 30 |

Usage errors return 64. An executed command returns its own exit code.

## Minimum BLOCK categories

- Recursive deletion of `/`, the home directory, or repository root.
- Hard reset, destructive Git clean, broad checkout/restore, and force push.
- Push or merge to `main`, push to a branch other than the current `work/<card-id>`, and deletion of
  `main` or the current local/remote work branch.
- Filesystem formatting and raw `dd` writes with an output target.
- Shutdown, reboot, and poweroff.
- Docker or Podman system prune and Kubernetes namespace deletion.
- Infrastructure destroy and `DROP DATABASE` or `DROP TABLE` statements.
- Dynamic execution and nested shells using `eval`, `sh -c`, `bash -c`, or equivalents.
- Command-string execution through POSIX/C shells, PowerShell variants, Windows command shells,
  `env`, or BusyBox wrappers.

## Minimum REVIEW categories

- Recursive deletion outside protected roots, including project build outputs.
- Branch deletion and non-force pushes.
- Merge or rebase while on a work branch, plus deletion of another inactive non-main branch.
- Broad process control, privilege elevation, and package removal.
- Destructive migrations and container, image, or volume removal.
- Commands outside known ALLOW patterns, including changes outside repository root.

The local log records classification metadata under `.local/`. It omits command arguments and the
reason text so credentials and sensitive values are not copied into the log. `.local/` must remain
ignored by Git.

The wrapper allows a non-force push only when repository state proves that the current branch is
`work/<card-id>` and the destination is that same branch. Work-branch add/commit operations are
allowed; add/commit on `main` is blocked. Promotion is not a REVIEW override: pushing or merging
to `main` through this agent wrapper is blocked. A future operator promotion path must authenticate
the operator and verify the accepted work commit independently.
