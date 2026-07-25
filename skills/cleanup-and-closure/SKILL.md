---
name: cleanup-and-closure
purpose: Remove scoped remnants and report truthful completion state.
---
# Cleanup and closure
## Use when
The operator requests bounded cleanup or closure evidence.
## Do not use when
Targets, ownership, recovery, or acceptance authority are unclear.
## Required context
Exact targets, lifecycle decision, state/cache/process locations, tests, and Git status.
## Procedure
Inventory; remove only authorized targets; verify absence and cleanup; report distinct statuses.
## Constraints
Preserve incident evidence; do not perform broad deletion or declare operator acceptance.
## Expected output
Removal inventory, checks, revision/publication state, and gaps.
## Evidence requirements
Absence scans, targeted tests, process/state inspection, and clean status where required.
## Stop conditions
Stop on ambiguous ownership, unrecoverable scope, or unexpected residue.
## Handoff
Return closure evidence for the operator's decision.
