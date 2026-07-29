# Enforcement map

| Policy | Current baseline enforcement | Project-specific extension |
|---|---|---|
| Scope and dirty state | AUTOMATED CHECK at agent startup | Optional project-specific checks |
| Evidence and status | SESSION RECEIPT plus OPERATOR DECISION | External receipt authentication |
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
| Command safety | AUTOMATED CHECK when wrapper is used | Exclusive agent-runner or terminal-adapter integration |

Startup and registered required checks are automated when the mandatory agent entrypoint and
command wrapper are used. Exclusive runner/terminal integration remains necessary to prevent
alternate execution paths.
