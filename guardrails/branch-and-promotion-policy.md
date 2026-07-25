# Branch and promotion policy

- Rule: Implementation occurs on one `work/<card-id>` branch created from verified `main`; only
  operator-approved work is promoted to `main`, which is verified again after merge.
- Purpose: Keep the baseline reproducible and prevent cards from contaminating one another.
- Applies when: A card changes version-controlled files or is considered for promotion.
- Prohibited behaviour: Direct implementation on `main`, mixed-card branches, promotion without
  operator approval, or reporting promotion before the merge and post-merge verification exist.
- Required evidence: Base commit, branch name, scoped diff, card-bound commit, operator decision,
  promotion commit, post-merge checks, remote state, and branch disposition where applicable.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may record a reasoned exception before work; remote protection
  and merge authority remain project-specific.
- Remaining limitations: The template does not configure host branch protection, perform merges,
  or close branches automatically.
