---
name: architecture-review
purpose: Review boundaries, ownership, dependencies, and operational consequences.
---
# Architecture review
## Use when
A change affects shared contracts, state, processes, or multiple components.
## Do not use when
The task is a trivial isolated edit with no architectural claim.
## Required context
Architecture records, system map, interfaces, constraints, and proposed change.
## Procedure
Trace dependencies, writers, runtime flows, failure modes, and alternatives.
## Constraints
Do not prescribe technology without project requirements or self-approve decisions.
## Expected output
Findings, tradeoffs, risks, and decision options.
## Evidence requirements
Connect claims to current implementation and documents.
## Stop conditions
Stop when ownership or required system context is unavailable.
## Handoff
Provide a decision-ready review to the operator.
