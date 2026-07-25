---
name: security-review
purpose: Review a bounded change for security, privacy, authority, and data exposure risks.
---
# Security review
## Use when
Changes handle trust boundaries, credentials, sensitive data, external input, or privileges.
## Do not use when
No defined target exists or specialist review is required but unavailable.
## Required context
Threat surface, data classification, deployment context, diff, and policies.
## Procedure
Map assets and boundaries; inspect validation, authorization, secrets, logging, and failure modes.
## Constraints
Do not claim exhaustive security or run intrusive tests without authority.
## Expected output
Prioritized findings, mitigations, unknowns, and decision needs.
## Evidence requirements
Tie each finding to a concrete path, scenario, or test.
## Stop conditions
Stop on live-secret exposure or unsafe testing conditions and notify the operator.
## Handoff
Return a bounded security report.
