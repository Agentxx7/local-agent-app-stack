# Canonical guardrails

1. One bounded card is active at a time.
2. Card identity is unique and each accepted card lands at most once.
3. Base revision, allowed paths, and patch identity are explicit.
4. Unknown dirty state blocks writing; foreign-owned dirty state requires operator review.
5. Scope mixing is separated or explicitly decided.
6. Tests identify the active production flow and version.
7. Processes, state, cache, assets, and generated data have owners and cleanup rules.
8. Each state domain has one canonical writer and source of truth.
9. Secrets, private paths, personal data, and credentials never enter evidence or version control.
10. Missing capabilities fail closed without hidden fallback.
11. Rejected material is absent from active code, tests, state, cache, and assets.
12. Automated success never equals operator approval.
13. Closure evidence is bound to the correct revision and publication state.
14. Cards remain short, bounded, copyable, and focused on one outcome.
