# Verification levels

- Implemented evidence: Diff or artifact demonstrates the scoped change.
- Static evidence: Structure, formatting, or analysis checks inspect the change without execution.
- Automated test evidence: Named checks run against an identified commit and environment.
- Production-path evidence: A check reaches the actual path used by the project.
- Manual evidence: A person observes a defined outcome and records context.
- Operational evidence: Runtime, deployment, state, and process behaviour are observed where relevant.
- Operator acceptance: The operator judges the collected evidence and limitations.
- Promotion evidence: The accepted commit is merged to `main` and the resulting baseline is
  verified independently of the work-branch result.

Select levels according to impact, uncertainty, risk, and complexity. No level silently grants the
next. Prefer a failing proof before code where practical and the real affected path afterward;
this template does not enforce either automatically.
