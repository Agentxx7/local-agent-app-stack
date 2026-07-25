# Dirty worktree policy

- Rule: Unknown dirty state stops new writes; known overlap needs ownership and a decision.
- Purpose: Prevent loss, contamination, and accidental mixed commits.
- Applies when: Before writing, staging, rollback, or handoff.
- Prohibited behaviour: Treating an unexplained dirty file as approved or disposable.
- Required evidence: Status, diff, provenance, owner, and disposition for affected changes.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may accept a documented baseline or overlap.
- Remaining limitations: Version-control status cannot explain semantic ownership by itself.
