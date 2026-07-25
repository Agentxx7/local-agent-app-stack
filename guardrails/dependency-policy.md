# Dependency policy

- Rule: Every new dependency needs a purpose, owner, version decision, provenance, and verification.
- Purpose: Control supply-chain, maintenance, licensing, and runtime risk.
- Applies when: Adding, replacing, updating, downloading, or enabling a dependency.
- Prohibited behaviour: Unowned dependencies, floating versions without rationale, or unverified availability.
- Required evidence: Decision record, source, version, license/risk review, and relevant tests.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may accept a documented exception and its risk.
- Remaining limitations: Concrete scanners and lockfile checks are project-specific.
