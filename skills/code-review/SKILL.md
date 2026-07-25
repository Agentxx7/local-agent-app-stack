---
name: code-review
purpose: Find correctness, regression, safety, and maintainability issues in a defined change.
---
# Code review
## Use when
The operator requests independent review of a diff or revision.
## Do not use when
No review target or acceptance criteria exist.
## Required context
Base/result revisions, diff, requirements, tests, and policies.
## Procedure
Trace changed behaviour, boundaries, failure paths, tests, and compatibility.
## Constraints
Review is read-only unless a separate fix card authorizes edits.
## Expected output
Findings ordered by severity with concise evidence.
## Evidence requirements
Reference exact files, behaviour, and reproducible checks.
## Stop conditions
Stop if the target changes or essential context is unavailable.
## Handoff
Return findings and residual risks to the operator.
