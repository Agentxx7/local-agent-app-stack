# Testing and production link

- Rule: Tests identify and reach the production path and version they claim to verify.
- Purpose: Prevent green results from stale, fallback, mocked-only, or disconnected flows.
- Applies when: A test is used as readiness, regression, or completion evidence.
- Prohibited behaviour: Unqualified green claims without target identity or negative coverage.
- Required evidence: Entry-point identity, version/revision, fixtures, assertions, and relevant negative tests.
- Enforcement type: WRITTEN RULE.
- Operator override: Narrow synthetic evidence may be accepted only with its limitation stated.
- Remaining limitations: Production equivalence requires project-specific integration evidence.
