# Verification levels

- Implemented evidence: Diff or artifact demonstrates the scoped change.
- Static evidence: Structure, formatting, or analysis checks inspect the change without execution.
- Automated test evidence: Named checks run against an identified commit and environment.
- Production-path evidence: A check reaches the actual path used by the project.
- Manual evidence: A person observes a defined outcome and records context.
- Operational evidence: Runtime, deployment, state, and process behaviour are observed where relevant.
- Operator acceptance: The operator judges the collected evidence and limitations.

Select levels according to impact, uncertainty, risk, and complexity. No level silently grants the
next, and this template does not enforce them automatically.
