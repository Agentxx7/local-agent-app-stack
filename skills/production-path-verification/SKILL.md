---
name: production-path-verification
purpose: Establish whether evidence reaches the real path affected by a bounded change.
---
# Production-path verification
## Use when
A test or status claim must be connected to actual application behaviour.
## Do not use when
No affected path or claim has been identified, or implementation is being requested without scope.
## Required context
Claim, commit, entry point, runtime boundaries, state and process effects, and available checks.
## Procedure
Trace the real path; map each check to it; run the strongest practical evidence; inspect state,
processes, cleanup, and residue; identify mocked, bypassed, dead, or untested segments.
## Constraints
Do not infer acceptance from green tests or substitute a convenient path for the affected path.
## Expected output
A claim-to-path-to-evidence map with results, unknowns, and limitations.
## Evidence requirements
Exact commands or observations, environment, commit, outputs, cleanup, and operator checks needed.
## Stop conditions
Stop when the path cannot be identified, required runtime access is absent, or evidence is unsafe.
## Handoff
Return findings for operator assessment and any narrowly scoped follow-up card.
