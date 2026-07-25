# Test integrity policy

- Rule: Tests must express the claimed behaviour, fail for the expected reason before a code fix
  where practical, and exercise or map to the real affected path.
- Purpose: Prevent irrelevant green tests, dead tests, and evidence that cannot support its claim.
- Applies when: Tests, checks, fixtures, production paths, or status claims change.
- Prohibited behaviour: Weakening a test to obtain green status, retaining tests for removed paths,
  substituting mocks for required integration evidence, or treating green tests as acceptance.
- Required evidence: RED result or justified alternative, GREEN result, test-to-production-path
  mapping, regression coverage, exact commit, limitations, and operator decision.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may accept a documented alternative proof or known gap; false or
  fabricated evidence is never an acceptable override.
- Remaining limitations: Projects must implement their own test runners, coverage, mutation,
  integration, and dead-test detection.
