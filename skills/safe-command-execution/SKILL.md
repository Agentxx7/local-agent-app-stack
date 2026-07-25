---
name: safe-command-execution
purpose: Classify agent-controlled terminal commands before execution and preserve operator authority.
---
# Safe command execution
## Use when
An agent needs to run or propose any terminal command in a project using the command gate.
## Do not use when
No terminal command is involved, or the project has not adopted and connected the wrapper.
## Required context
Card ID, repository root, exact argv, allowed command categories, prohibited commands, and any
operator decision covering a REVIEW command.
## Procedure
Run check-only first when classification is uncertain. Execute ALLOW through the wrapper. For
REVIEW, stop until the operator supplies a decision ID, reason, and exact scope, then pass the
unchanged argv. For BLOCK, do not execute; report the command category and required outcome.
## Constraints
Never use dynamic execution, nested shell bypass, reconstructed command strings, fabricated
approval, or direct terminal execution outside the wrapper. A work agent may add, commit, and
non-force push only its current `work/<card-id>` branch. It must not push or merge to `main`, delete
`main`, or delete its active work branch through the wrapper.
## Expected output
Classification, exit code, execution result if allowed, decision ID for REVIEW, and blocked or
unresolved commands.
## Evidence requirements
Command category, sanitized gate log reference, operator record, exact scope, and residue or Git
status checks when the command can change state.
## Stop conditions
Stop on BLOCK, missing REVIEW approval, ambiguous scope, wrapper failure, suspected bypass, or a
classification that conflicts with known effects.
## Handoff
Report executed REVIEW commands, decision IDs, BLOCK results, bypass attempts, and remaining gaps
to the operator, then stop after the current work branch is pushed. Classification is not operator
acceptance or promotion authority. Main promotion requires a separate authenticated operator path.
