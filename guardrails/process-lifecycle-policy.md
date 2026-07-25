# Process lifecycle policy

- Rule: Every process has an owner, identity, timeout, shutdown path, and deterministic cleanup.
- Purpose: Prevent hangs, orphans, foreign-process signalling, and stale resources.
- Applies when: Code or scripts create, supervise, reconnect to, or terminate processes.
- Prohibited behaviour: Unbounded waits, ambiguous identity, ownerless daemons, or blind termination.
- Required evidence: Lifecycle design, identity checks, timeout tests, cleanup tests, and process inspection.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may approve a documented lifecycle exception before activation.
- Remaining limitations: Runtime enforcement must be implemented and tested by each project.
