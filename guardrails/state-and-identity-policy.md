# State and identity policy

- Rule: Every capability is classified stateless or stateful before implementation; every stateful
  capability names one canonical identity model (where identity is required), one canonical state
  vocabulary, one transition vocabulary, and one canonical owner.
- Purpose: Prevent shadow state, invented lifecycles, and identity used as a substitute for
  lifecycle state.
- Applies when: Designing, reviewing, or extending any capability, module, interface, or
  persistence adapter.
- Prohibited behaviour: Interface-owned duplicate canonical state, IDs introduced for symmetry
  alone, inferring state from identity or identity from state, persistence adapters defining domain
  lifecycle semantics, and treating every error as permanent domain state.
- Required evidence: Recorded stateless/stateful classification, identity model if any, state
  vocabulary, transition vocabulary, canonical owner, and — where concurrency is possible — the
  project's stale-write and idempotency decision.
- Enforcement type: WRITTEN RULE.
- Operator override: The operator may accept a documented exception, such as a temporary secondary
  representation during a migration, with its risk and closure plan recorded.
- Remaining limitations: Static documentation cannot prove runtime ownership exclusivity; this is
  the same limitation `guardrails/source-of-truth-policy.md` records for state domains generally.

## Stateless vs. stateful

- **Stateless capability**: `input → canonical operation → result`. Bounded execution, no durable
  lifecycle, no resume requirement. An identifier is introduced only when a real caller need exists
  (for example, correlating a later log entry) — never for architectural symmetry with stateful
  capabilities.
- **Stateful capability**: `canonical identity (where required) → canonical state → explicit
  transition → new canonical state → persistence (where lifecycle survival requires it)`. Present
  when a capability has any of: pause/resume, retries that depend on prior attempts, an observable
  state that outlives one call, ownership shared across interfaces, or a recovery expectation after
  restart.
- Each capability records this classification once, where its ownership is documented (for example
  a module's state-ownership field). Moving a capability from stateless to stateful is a decision,
  not an accident.

## Identity, state, and persistence

- Identity defines what an entity is.
- State defines where that entity currently sits in its lifecycle.
- Persistence — when a project chooses it — is the mechanism that lets identity and state survive
  past a single process execution.
- Identity is not state: an ID must never substitute for lifecycle state, and lifecycle state must
  never be inferred from the shape or presence of an ID.
- State is not persistence: a capability can be stateful with only in-memory or process-local
  state; persistence is required only when the project needs that state to survive an execution or
  process boundary.
- Storage is not canonical domain state: a database, file, or blob is a durable representation
  chosen to hold state; the adapter that reads or writes it does not thereby own the domain
  semantics of that state. See "Persistence boundary" below.

## Canonical ownership

For each stateful capability:

- One canonical identity model, where identity is required.
- One canonical state vocabulary.
- One canonical transition vocabulary.
- One canonical owner — the domain or core component responsible for that capability, consistent
  with the `Domain` layer in `ARCHITECTURE.md`'s canonical identity and data-flow chain.

Interfaces (CLI, API, UI, MCP, or any other surface) may observe canonical state, request a
canonical transition, and present state to a user or caller. Interfaces must not own a duplicate or
shadow representation of that state, reconstruct an alternate lifecycle, decide a transition
independently of the canonical owner, or persist a competing representation of the same lifecycle.
This extends the existing rule in `guardrails/source-of-truth-policy.md` — "Each state domain names
one canonical source of truth and its permitted writers" — by naming the interface-boundary failure
mode explicitly.

## Transitions

- Transitions are explicit: a state change is a named operation, not an incidental side effect of
  an unrelated write.
- Transition semantics belong to the domain/core owner named above; interfaces request a
  transition, they do not implement one.
- Invalid transitions fail closed — reject rather than silently coerce, ignore, or default to an
  assumed state — consistent with the fail-closed defaults already required in
  `guardrails/command-safety-policy.md` and `guardrails/command-runner-contract.md`.
- State mutation occurs only through the canonical owner's seam; no adjacent layer writes canonical
  state directly.
- This policy does not mandate a specific state-machine implementation, library, or notation. The
  adopting project chooses how transitions are expressed.

## State categories

Distinguish, where a project actually has them, without requiring every project to use every
category:

- Transient or process-local runtime state.
- Interface or presentation state (for example, form state or a UI's own view of progress).
- Cached or derived state (recomputable from canonical state; its loss is not data loss).
- Canonical domain state (the authoritative current lifecycle position).
- Durable canonical domain state (canonical state that has been persisted).
- Historical state — transition records, events, or observations.

These categories must not become interchangeable. A cache is not a source of truth. Presentation
state is not domain state. See `health/state-health.md` for tracking these once a project selects
them.

## Current state vs. history

Current state and historical fact are different concepts and must not be silently treated as the
same thing. A project that needs history — an audit trail, a transition log, a prior-state record —
defines its ownership and semantics explicitly, alongside the canonical owner named above. This
policy does not mandate event sourcing, an immutable ledger, or any other history mechanism; a
project with no history requirement adds none.

## Persistence boundary

Persisted domain semantics — the entity, its identity if any, and its state vocabulary — are
defined before a storage technology is selected, consistent with `PROJECT.md`'s "Source of truth"
section and `ARCHITECTURE.md`'s `Storage → Domain` direction. Storage and persistence adapters
store and retrieve the canonical representation; they do not define or own domain lifecycle
semantics. This policy does not prescribe SQL, NoSQL, object storage, event sourcing, or any other
technology; that remains project-specific, as `database/README.md` already states.

## Recovery and resume

When a stateful capability must survive process termination:

- Recovery belongs to that capability's canonical owner, not to any interface.
- An interface must not invent its own recovery or resume behaviour.
- Resume operates from canonical state, not from an interface's cached or presentation-local view.
- An incomplete or invalid recovered state fails safely rather than being guessed into a valid one.

Stateless capabilities have no recovery requirement. This is distinct from
`guardrails/process-lifecycle-policy.md`, which governs the lifecycle of OS-level processes (owner,
timeout, shutdown, cleanup); this section governs the domain state a stateful capability must
recover once its process is running again.

## Failure state

A typed execution error or runtime failure is not automatically domain state. A failure becomes
canonical lifecycle state only when the domain explicitly defines that semantics — for example, a
terminal `FAILED` state a workflow can report or retry from. Absent that explicit definition, errors
are handled as errors, not written into the canonical state vocabulary.
`guardrails/rejected-material-policy.md` remains the governing rule for the specific case of a
permanently rejected capability or artifact.

## Concurrency

Where concurrent transitions on the same canonical state are possible, the adopting project
explicitly defines ownership for: stale writes, atomic-transition requirements, idempotency where
necessary, and how competing transitions are resolved. This policy states the requirement to
decide, not a locking or consensus mechanism; the mechanism remains project-specific.

## Non-goals

This policy does not require a universal `Job` or `OperationId` abstraction, IDs for every action,
mandatory persistence, a mandatory database, mandatory event sourcing or an immutable ledger,
mandatory queues or an Inbox/Outbox pattern, a mandatory scheduler, mandatory distributed execution,
a mandatory state-machine framework, or one global lifecycle enum shared across unrelated domains. A
capability correctly classified as stateless carries none of this machinery.
