# Contributing

Thank you for your interest in contributing to this repository. This document defines the
process for proposing a change to the canonical upstream repository.

## Before you start

1. **Fork the repository, or create a work branch if you already have write access.**
   External contributors fork; collaborators with existing write access create a
   `work/<card-id>` branch directly from verified `main`.
2. **Never commit directly to canonical `main`.** All changes go through a work branch and a
   pull request, regardless of contributor role.
3. **Keep each change bounded to one frontier.** One pull request should correspond to one
   defined, scoped unit of work (one card or issue), not a mixture of unrelated changes.
4. **Update documentation and diagrams when behaviour or architecture changes.** If a change
   affects what a document or diagram describes, update that document or diagram in the same
   pull request. Do not leave the repository's documentation contradicting its actual state.
5. **Run the relevant tests and verification scripts.** Before opening a pull request, run the
   tests and verification scripts relevant to the paths you changed (for example
   `scripts/verify-structure.sh`, `scripts/verify-operating-model.sh`, or the test suite under
   `scripts/tests/`, as applicable to your change).

## Opening a pull request

Every pull request must state:

- **Scope** — what the change is intended to accomplish and why.
- **Changed paths** — the exact files and directories touched.
- **Tests run** — the exact test and verification commands executed, and their results.
- **Evidence** — concrete proof the change works as described (command output, logs, or
  equivalent verifiable artifacts).
- **Remaining limitations** — anything the change does not address, known gaps, or follow-up
  work left for a future frontier.

Use `.github/PULL_REQUEST_TEMPLATE.md` as the starting point; it captures these fields.

## Review and acceptance

- Maintainers decide whether a contribution is accepted, requires changes, or is declined.
  There is no guarantee that a given contribution will be reviewed on any particular timeline
  or accepted at all.
- Opening a pull request does not grant write or merge permission on the repository. Only a
  maintainer can merge an accepted pull request into `main`.
- CODEOWNERS review becomes a technically required gate only when a corresponding GitHub
  ruleset or branch-protection setting enabling required reviews is enabled on the repository.
  In the absence of such a setting, the `CODEOWNERS` file documents expected ownership but does
  not by itself block a merge.

## Code of conduct

Be respectful and constructive in issues, pull requests, and reviews. Focus feedback on the
change, not the contributor.
