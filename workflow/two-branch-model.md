# Two-branch model

This is one permanent baseline branch and one isolated branch for the active card, not two
permanent development branches.

## `main`

- Permanent protected baseline.
- Contains only verified, operator-approved work.
- Receives no direct implementation work.
- Remains buildable, testable, and reproducible according to the adopted project's checks.

## `work/<card-id>`

- Short-lived branch created from verified `main`.
- Owned by exactly one card.
- Contains only that card's tests and changes.
- Never mixes work from another card.
- Is merged only after an operator decision.
- Is closed after promotion or rejection.

Branch protection is a repository-host setting that the adopting project must configure. This
document and the template scripts do not claim to enforce remote protection, merge authorization,
or branch deletion.
