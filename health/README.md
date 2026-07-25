# Health

This directory contains evidence-based templates for recording project health without inventing
results. Allowed states are `HEALTHY`, `DEGRADED`, `BLOCKED`, `UNKNOWN`, and `NOT CHECKED`.
`HEALTHY` requires relevant, current evidence. A missing check stays `NOT CHECKED`; an
inconclusive check stays `UNKNOWN`. The operator reviews the evidence and records the decision.

Each project selects the checks, tools, scope, and verification frequency appropriate to it.
Update relevant health records after verified promotion when new evidence changes a known state,
failure, unknown, or risk. A work-branch result alone does not establish the health of `main`.
