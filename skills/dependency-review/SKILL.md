---
name: dependency-review
purpose: Evaluate the need, provenance, versioning, and operational impact of a dependency.
---
# Dependency review
## Use when
A dependency is added, replaced, updated, downloaded, or activated.
## Do not use when
No dependency change is proposed.
## Required context
Purpose, owner, source, version, license, runtime use, and alternatives.
## Procedure
Confirm necessity; inspect provenance and maintenance; assess footprint, permissions, and tests.
## Constraints
Do not download, install, or approve a dependency without card authority.
## Expected output
Recommendation, risks, required evidence, and unresolved questions.
## Evidence requirements
Use authoritative metadata and project-relevant verification.
## Stop conditions
Stop on unknown provenance, unacceptable license, or missing operator decision.
## Handoff
Return a dependency decision package.
