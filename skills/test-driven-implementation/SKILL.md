---
name: test-driven-implementation
purpose: Implement a bounded code card using failing proof, minimal change, refactoring, and evidence.
---
# Test-driven implementation
## Use when
A scoped card changes executable behaviour and a failing proof is practical.
## Do not use when
The task is read-only, lacks an approved scope, or requires a different verifiable prior proof.
## Required context
Card ID, base commit, work branch, allowed paths, expected behaviour, constraints, and test entry points.
## Procedure
Prove RED for the right reason; make the smallest GREEN change; REFACTOR without behaviour change;
run relevant regression and real-path checks; bind the report to the commit.
## Constraints
One card and branch only; do not weaken tests, select technology, self-approve, or work on `main`.
## Expected output
Scoped changes plus separate RED, GREEN, refactor, verification, and status results.
## Evidence requirements
Commands, outputs, affected-path mapping, diff, commit, Git status, uncertainties, and gaps.
## Stop conditions
Stop on wrong branch or base, unknown dirty state, invalid RED, scope conflict, or missing authority.
## Handoff
Return the evidence report to the operator; the operator decides promotion.
