# Enforcement map

| Guardrail area | Preferred enforcement | Operator responsibility |
|---|---|---|
| Card identity and replay | Ledger/preflight plus tests | Confirm semantic uniqueness |
| Dirty state and exact scope | Version-control checks | Decide foreign ownership |
| Test isolation and flow identity | Test harness and runtime assertions | Judge evidence relevance |
| Process and state lifecycle | Runtime checks and integration tests | Approve risky activation |
| Secrets and private paths | Static scans and hooks | Classify ambiguous findings |
| Rejected removal | Repository/runtime/state scans | Confirm completeness |
| Closure and `KLAR` | Commit-bound receipt | Explicitly accept or reject |
