# First project specification

The first specification card turns the skeleton into a defined project. It does not implement anything. It records the decisions that let later frontiers stay small and verifiable.

## When to write it

Write this immediately after creating the repository and before creating any work branch for implementation. It is the operator's responsibility, not the agent's.

## Required sections

A valid first specification card must contain all of these sections. Use `cards/task-card-template.md` as the shell and expand the fields below.

### 1. Project identity

- Project name
- Repository location
- Owning team or operator
- Date of specification

### 2. Problem statement

Describe the problem the project solves in one or two sentences. Avoid solution language.

### 3. Intended users

List the humans or systems that interact with the project.

### 4. First usable outcome

Define the smallest thing a user can do that proves value. This is the target of the first implementation frontier, not the whole project.

### 5. Locked decisions

Record decisions that are already made and must not be reopened without a new operator decision:

- Programming language and runtime
- Framework or platform, if any
- Data store
- Authentication and authorization approach
- Hosting or deployment target
- Branch and promotion model

### 6. Architecture boundaries

List the major layers or components and the direction of dependencies. Do not design every detail; mark unknown areas explicitly.

### 7. Canonical data flow

Describe the happy-path data flow for the first usable outcome. Use concrete IDs, statuses, and operations.

### 8. Source of truth

Name the authoritative store for each kind of state. Avoid multiple sources of truth for the same fact.

### 9. Security and data handling

- Authentication method
- Authorization rules
- Sensitive data classes
- Audit and immutability requirements
- Retention or deletion rules

### 10. In scope

What the first release or first set of frontiers will cover.

### 11. Out of scope

What is deliberately excluded. This protects the project from creeping frontiers.

### 12. First frontier

A bounded card definition with:

- Card ID
- Work branch name
- Goal
- Affected paths
- Out of scope for this frontier
- RED evidence
- Acceptance criteria
- Verification commands
- Stop conditions

### 13. Verification strategy

How the project will prove correctness at unit, integration, and end-to-end levels. Include the real commands where known.

## RED evidence for the first specification

The first specification card itself is not code, so its RED evidence is a documentation contract check:

```bash
bash scripts/verify-operating-model.sh
```

The check fails if required operating-model files are missing, empty, or contradictory. The first specification is valid only when this check passes.

## Link to the full workflow

See `docs/adopting-the-template.md` for the complete adoption lifecycle.
