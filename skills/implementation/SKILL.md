---
name: implementation
purpose: Implement one approved bounded card and verify the result.
---
# Implementation
## Use when
An operator-approved card defines outcome, scope, and boundaries.
## Do not use when
The task is analysis-only, scope is unknown, or dirty state is unexplained.
## Required context
Card, base revision, repository policy, affected code, and acceptance criteria.
## Procedure
Inspect; implement only scope; add proportionate tests; review diff; report evidence.
## Constraints
Preserve unrelated work; avoid hidden fallback, unapproved dependencies, and self-approval.
## Expected output
Bounded changes and a verification report.
## Evidence requirements
Named tests, diff scope, revision/Git state, and known gaps.
## Stop conditions
Stop on missing authority, destructive ambiguity, or a materially different required design.
## Handoff
Return results to the operator without declaring acceptance.
