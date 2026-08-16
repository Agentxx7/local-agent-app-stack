# Project

This file records the adopted project identity and the operator decision that the repository has moved from `template` to `project`. Do not treat this file as optional. Missing or contradictory project status blocks writing work fail-closed.

## Template vs project

- `template`: the complete published skeleton inventory.
- `project`: an adopted repository with a defined project specification.

The transition is an explicit operator decision recorded below. It does not happen implicitly by deleting directories.

## Project identity

- Name:
- Repository:
- Owner or operator:
- Date adopted:

## Problem statement

Describe the problem the project solves.

## Intended users

Who will use or operate the system?

## First usable outcome

What is the smallest valuable behaviour a user can experience?

## Locked decisions

- Programming language and runtime:
- Framework or platform:
- Data store:
- Authentication and authorization:
- Hosting or deployment target:
- Branch and promotion model:

## Architecture boundaries

List the major layers or components and dependency direction. Mark unknowns explicitly.

## Canonical data flow

Describe the happy-path data flow for the first usable outcome.

## Source of truth

Name the authoritative store for each kind of state. For stateful capabilities, also record the
canonical identity model, state vocabulary, transition vocabulary, and owner, per
`guardrails/state-and-identity-policy.md`.

## Security and data handling

- Authentication method
- Authorization rules
- Sensitive data classes
- Audit and immutability requirements
- Retention or deletion rules

## In scope

What the first release or first set of frontiers covers.

## Out of scope

What is deliberately excluded.

## First frontier

- Card ID:
- Work branch:
- Goal:
- Affected paths:
- Out of scope for this frontier:
- RED evidence:
- Acceptance criteria:
- Verification commands:
- Stop conditions:

## Adoption checklist

- [ ] Repository created from template or fork
- [ ] Repository renamed
- [ ] This file completed
- [ ] `ARCHITECTURE.md` completed
- [ ] First specification card created from `cards/task-card-template.md`
- [ ] First frontier card created with a valid `work/<card-id>` branch
- [ ] RED evidence defined before implementation
- [ ] Operator explicitly records transition from `template` to `project`

## Operator decision

I confirm that this repository is now a `project` and that the first frontier may proceed.

- Operator:
- Date:
- Decision ID:

For a copy-paste example, see `docs/adopting-the-template.md`.
