---
name: testing-and-verification
purpose: Select and run evidence proportionate to the claims and risk.
---
# Testing and verification
## Use when
A change or status claim needs reproducible evidence.
## Do not use when
Tests would affect real state or services without explicit authority.
## Required context
Claim, production path, risk, test commands, isolation, and expected results.
## Procedure
Choose positive/negative checks; isolate state; run bounded tests; inspect actual outputs.
## Constraints
Do not equate green tests with operator approval or hide skipped checks.
## Expected output
Test matrix, results, failures, skips, and confidence limits.
## Evidence requirements
Record command, target revision/version, environment, and exit result.
## Stop conditions
Stop on unsafe state access, hangs, unknown ownership, or false test targeting.
## Handoff
Return verification evidence and remaining gaps.
