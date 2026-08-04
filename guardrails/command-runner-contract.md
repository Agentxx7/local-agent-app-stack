# Command runner contract

## Purpose

This document defines the canonical, technology-neutral contract that every
adopted-project command runner must satisfy when it executes agent-controlled
terminal commands. It is a contract, not an implementation. It does not select
a programming language, framework, or runtime, and it does not itself execute
commands.

**ENFORCEMENT REMAINS NOT_PRESENT ON THE TEMPLATE MAIN BRANCH.** This document
describes what a compliant runner must do. No file in this repository
implements a runner, and nothing on `main` technically forces any command
through one. See `guardrails/command-safety-policy.md` and
`guardrails/enforcement-map.md` for the current, unchanged enforcement
classification.

## Relationship to `scripts/command-gate.sh`

`scripts/command-gate.sh` already implements the classification half of this
contract: given an argv, it returns `ALLOW`, `REVIEW`, or `BLOCK`, and it
enforces the decision when it is the thing invoked. This contract generalizes
that behaviour into a request/result shape that a project-owned runner —
whatever language or runtime it is written in — can implement natively,
instead of shelling out to a Bash script for every command. A conforming
runner may call `scripts/command-gate.sh` internally, reimplement equivalent
classification logic, or use a proven behaviour-equivalent classifier; this
contract does not mandate which.

## Scope classification

This frontier's target classification is **COMBINATION_REQUIRED**:

- The template owns the contract, the classifier, and the conformance tests.
- An adopted project owns the actual runner implementation and the wiring of
  every agent-facing command surface through it.
- The host, container, or agent harness owns preventing raw shell execution
  outside the runner and enforcing OS-level isolation.

No single layer can satisfy this contract alone. A runner without a
classifier is not compliant. A classifier without an exclusive execution path
is not enforcement. A project without host-level containment cannot claim
enforcement no matter how correct its runner is.

## Canonical request contract

Every command execution request a runner accepts must be representable with
at least the following fields. Field names are canonical identifiers for this
contract; a concrete runner may use its own type or serialization as long as
the same information is present and the same constraints hold.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `argv` | ordered array of strings | yes | The literal executable and its arguments, one array element per argument. Never a single shell command string. |
| `cwd` | string (path) | yes | The working directory the command is requested to run in. |
| `env_allowlist` | array of strings | yes | Names of environment variables permitted to reach the child process. An empty array means no environment variables beyond the runner's own minimal baseline are passed through. |
| `timeout_seconds` | number | yes | The maximum wall-clock duration the runner will allow the command to run before it is cancelled. |
| `operator_decision_id` | string | optional | Present only when the command's classification requires operator approval. Identifies the specific operator decision being invoked. |
| `operator_reason` | string | optional | Present only alongside `operator_decision_id`. The human-readable justification recorded with that decision. |

### Request invariants

- `argv` is never accepted as a shell command string. A runner that parses a
  single string into arguments by splitting on whitespace, or that hands a
  string to a shell for interpretation, does not satisfy this contract.
- Argument boundaries are preserved exactly as supplied from `argv` through to
  the spawned process; no re-quoting, re-joining, or re-splitting step may
  occur between request and execution.
- `cwd` must remain within project-approved roots. A runner must reject or
  re-classify a request whose `cwd` resolves outside the set of directories
  the adopted project has designated as valid execution roots.
- Environment variables are deny-by-default. Only names explicitly present in
  `env_allowlist` may be forwarded into the child process; nothing is
  forwarded by ambient inheritance.
- `operator_decision_id` and `operator_reason`, when present, are request
  metadata only. Their presence does not itself authorize execution — see the
  result contract and state transitions below.

## Canonical result contract

Every command execution result a runner produces must be representable with
at least the following fields.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `classification` | enum: `ALLOW` \| `REVIEW` \| `BLOCK` | yes | The decision reached for this request before any execution was considered. |
| `category` | string | yes | The specific classification category (for example `git-force-push`, `recursive-delete`, `unknown-or-ambiguous`) that produced the classification. |
| `argv_digest` | string | yes | A deterministic digest of the normalized `argv`, computed without exposing raw argument content, sufficient to compare a later approval against the exact scope originally classified. |
| `scope_digest` | string, nullable | yes (nullable) | The digest of the scope an operator approved for a `REVIEW` request. Null or absent when no operator approval applies. |
| `redaction` | string | yes | A statement of what was withheld from logs (for example `argv-and-reason-omitted`). Never the sensitive content itself. |
| `exit_code` | integer, nullable | yes (nullable) | The process exit code. Null when execution did not occur (`BLOCK`, unapproved `REVIEW`, or a cancelled/timed-out command that never produced an exit code). |
| `timed_out` | boolean | yes | Whether the command was terminated for exceeding `timeout_seconds`. |
| `cancelled` | boolean | yes | Whether the command was terminated by an explicit cancellation request rather than completing or timing out. |
| `stdout_ref` | string, nullable | yes (nullable) | A reference (path, handle, or identifier) to captured standard output, or null when none was captured or execution did not occur. Never the raw stream content inlined into a result field that might be logged unredacted. |
| `stderr_ref` | string, nullable | yes (nullable) | The equivalent reference for captured standard error. |

### Result invariants

- `classification` of `BLOCK` never executes. A result with `classification:
  BLOCK` must always have `exit_code: null`, `timed_out: false`, `cancelled:
  false`.
- `classification` of `REVIEW` never executes without a matching operator
  decision. A `REVIEW` result may only carry a non-null `exit_code` if the
  request's `operator_decision_id` and `operator_reason` were present and the
  approved scope digest matches `argv_digest` exactly.
- Operator approval must match the approved scope digest. An operator
  decision recorded against one `argv_digest` never authorizes execution of a
  request whose `argv_digest` differs, even if the difference is a single
  added flag or argument.
- Unknown or ambiguous commands remain `REVIEW`. A runner must not default an
  unrecognized command to `ALLOW`.
- Raw secrets and full sensitive argv are not logged. Evidence records use
  `argv_digest`, `category`, and `redaction`, never the literal argument
  values or `operator_reason` text.
- An execution result is emitted only after actual execution completes,
  times out, or is cancelled. A runner must never emit a populated
  `exit_code` before the child process has actually run.

## Required state transitions

```
request → classify → { ALLOW, REVIEW, BLOCK }

ALLOW   → execute → result(exit_code set, timed_out/cancelled as applicable)

BLOCK   → result(exit_code: null) — never executes, regardless of any
          operator_decision_id supplied on the request.

REVIEW, no operator_decision_id/operator_reason
        → result(exit_code: null) — never executes.

REVIEW, operator_decision_id + operator_reason present,
        scope_digest matches argv_digest
        → execute → result(exit_code set, timed_out/cancelled as applicable)

REVIEW, operator_decision_id + operator_reason present,
        scope_digest does NOT match argv_digest
        → result(exit_code: null) — never executes; treated as an
          unauthorized scope, not as a valid approval.
```

Cancellation and timeout are cross-cutting: any execution in progress under
`ALLOW` or approved `REVIEW` may end in `timed_out: true` or `cancelled: true`
instead of a normal exit, but never in place of the classification gate
above. A command that has not started executing is never marked `timed_out`.

## Responsibility split

### Template-owned requirements (this repository)

- The contract itself: the request schema, result schema, invariants, and
  state transitions defined in this document.
- Command classification policy (`guardrails/command-safety-policy.md`) and
  the reference classifier (`scripts/command-gate.sh`).
- Conformance tests that verify the contract document and classifier stay
  consistent with each other (`scripts/tests/command-runner-contract-test.sh`,
  `scripts/tests/command-gate-test.sh`).
- Adoption guidance describing how a project connects a runner to this
  contract (`docs/adopting-the-template.md`).
- Explicitly documenting that enforcement is `NOT_PRESENT` on `main` until an
  adopted project completes its own wiring.

### Adopted-project responsibilities

- Choosing the project's runtime and implementing exactly one project-owned
  runner in that runtime.
- Wiring every agent-facing command surface (CLI, IDE integration, agent
  harness tool, CI step, or any other entry point an agent can use to run a
  command) through that one runner, with no parallel path.
- Implementing timeout, cancellation, `cwd` confinement, and environment
  allowlisting inside its chosen runtime, consistent with the invariants
  above.
- Connecting operator approval records to the exact `scope_digest` a runner
  computes, so that approval can never be reused outside its original scope.
- Extending the conformance suite with project-specific tests exercising its
  actual runner binary or endpoint.
- Deciding, and recording, when (if ever) to upgrade its own enforcement
  classification from `NOT_PRESENT` to `PARTIALLY_ENFORCED` or `ENFORCED` —
  this template never makes that claim on a project's behalf.

### Host / container / harness responsibilities

- Preventing raw shell execution outside the runner at the OS or sandbox
  level (for example, restricting which binaries or syscalls a process tree
  can invoke).
- Filesystem and process isolation, so that a runner's `cwd` confinement and
  environment allowlisting are backed by real boundaries rather than
  cooperative behaviour alone.
- OS-level permission boundaries (user, container, or VM isolation) that hold
  even if a runner implementation has a defect.

None of these three layers substitutes for another. A project cannot claim
compliance by implementing a runner but leaving other agent-facing surfaces
unwired, and it cannot claim enforcement by relying on host isolation alone
without a runner that satisfies the request/result contract above.

## Non-goals

- This contract does not specify a wire format, IPC mechanism, or API shape.
  Any serialization that preserves the fields and invariants above is
  acceptable.
- This contract does not require a specific digest algorithm, only that the
  digest be deterministic and computed without exposing the raw sensitive
  content it stands in for.
- This contract does not claim that any runner exists in this repository. It
  defines what one must do if and when a project builds one.
