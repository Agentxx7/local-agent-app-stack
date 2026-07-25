# Process health

- Every process has one owner and request or session identity.
- PID or equivalent identity is verified before signalling.
- Start, readiness, deadline, termination, escalation, and cleanup are bounded.
- Foreign processes are never signalled.
- No orphan remains after completion or shutdown.
