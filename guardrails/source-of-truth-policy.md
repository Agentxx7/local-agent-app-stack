# Source of truth policy

- Rule: Each state domain names one canonical source of truth and its permitted writers.
- Purpose: Avoid conflicting state, duplicate writers, and misleading projections.
- Applies when: Introducing persistence, cache, registries, configuration, or derived views.
- Prohibited behaviour: Competing canonical stores or undocumented write paths.
- Required evidence: Ownership map, writer list, synchronization rules, and failure behaviour.
- Enforcement type: WRITTEN RULE.
- Operator override: Multiple writers require an explicit consistency design and decision.
- Remaining limitations: Static documentation cannot prove runtime writer exclusivity.
