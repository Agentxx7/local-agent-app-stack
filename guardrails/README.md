# Guardrails

These reusable policies define a general safety and quality baseline. Unless a project wires a
real check or runtime control and records evidence, enforcement is `WRITTEN RULE` or
`OPERATOR DECISION`, never automatic. The operator owns exceptions and final decisions.

The baseline includes branch and promotion boundaries plus test-integrity rules. Projects must
configure their own host protection, test tooling, and runtime controls; these documents do not
claim that such enforcement exists.

`command-safety-policy.md` is the exception: its ALLOW/REVIEW/BLOCK decision is an automated
pre-execution check when `scripts/command-gate.sh` is used. It does not intercept other terminal
paths, so projects must wire their runner or adapter to the wrapper for complete enforcement.

Allowed enforcement types: `WRITTEN RULE`, `AUTOMATED CHECK`, `RUNTIME ENFORCEMENT`, and
`OPERATOR DECISION`.
