# Enforcement map

| Policy | Current baseline enforcement | Project-specific extension |
|---|---|---|
| Scope and dirty state | WRITTEN RULE | Optional Git/preflight checks |
| Evidence and status | OPERATOR DECISION | Optional receipt checks |
| Destructive commands | WRITTEN RULE | Optional wrappers or permissions |
| Sensitive data | WRITTEN RULE | Optional scanners and hooks |
| Dependencies | WRITTEN RULE | Optional policy and supply-chain checks |
| Process lifecycle | WRITTEN RULE | Runtime enforcement and lifecycle tests |
| Source of truth | WRITTEN RULE | Architecture/runtime consistency checks |
| Testing link | WRITTEN RULE | Integration and production-path assertions |
| Rejected material | OPERATOR DECISION | Repository/runtime/state absence checks |
| Incident follow-up | OPERATOR DECISION | Issue or ledger automation if selected |
| Branch and promotion | WRITTEN RULE | Host branch protection and merge checks |
| Test integrity | WRITTEN RULE | Test, coverage, mutation, and production-path checks |

This map reports no automated or runtime enforcement in the skeleton itself.
