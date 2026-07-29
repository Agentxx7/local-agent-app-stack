# Task: Command gate safety and closure verification

- Card ID: `TEMPLATE-COMMAND-SAFETY-001`
- Base commit: `55f1990552e36b1764701a474036198c32efde3c` (`main` at implementation baseline)
- Work branch: `work/TEMPLATE-COMMAND-SAFETY-001`
- Implementation HEAD before closure evidence: `87487d1e841227a9e6505adce30aa8c56afb9397`
- Goal: Make the existing technology-neutral command gate implementation verifiable and ready for operator review.
- Context: The implementation was created in five existing commits between the baseline and implementation HEAD. This card was added afterward to bind the existing work to its frontier and record current verification truthfully; it does not reconstruct or rewrite earlier history.
- Implementation commits:
  - `ec1eb96` Add pre-execution command safety guard
  - `74637f9` Harden command gate Git and shell boundaries
  - `e065f97` Close command gate deletion and interpreter bypasses
  - `99dbf85` Finalize command gate parsing fixes
  - `87487d1` Document operator-controlled agent architecture
- Allowed scope and paths: Existing command-gate implementation, its fixtures, command-safety documentation, and this frontier evidence card.
- Prohibited changes: Agent bootstrap, session receipts, guardrail registry, product-specific rules, history rewriting, promotion or merge to `main`.
- Allowed command categories: Registered verification, shell syntax checks, Git read operations, commit and non-force push on the current work branch.
- Prohibited commands: Force push, mutation of `main`, branch deletion, promotion, and commands outside this frontier.
- REVIEW commands expected: Yes, limited to the exact read-only inspection approved for closure audit.
- Operator decision ID for approved REVIEW commands: `APPROVE_TEMPLATE_COMMAND_SAFETY_CLOSURE_READS_004` (inspection only; not implementation acceptance).
- Expected result: All command-gate fixtures, structure checks, operating-model checks, Bash syntax checks, and Git hygiene checks pass.
- Expected behaviour or claim: Agent-controlled commands are classified as ALLOW, REVIEW, or BLOCK; BLOCK cannot be overridden; REVIEW requires decision metadata; approved commands execute as the original argv array; protected Git and destructive or reconstructed command paths fail closed.
- Failing proof (RED) or justified alternative: No historical RED/GREEN evidence is claimed. The five implementation commits predate this closure card. Any failure observed during the current verification must be recorded before an in-scope repair and rerun.
- Verification, including real affected path: Executed in this closure round against `scripts/command-gate.sh`, `scripts/tests/command-gate-test.sh`, the template structure, and the operating-model documentation. All required checks passed as recorded below.
- Prior operator acceptance: Missing. No `operator_accepted` evidence was found before this closure round.
- Prior closure or promotion: Missing. No `LANDED`, `CLOSED`, or `PROMOTED` evidence was found, and the implementation is not on `main`.
- Stop conditions: Stop on any out-of-scope failure, any required REVIEW without an exact operator decision, or any request to promote or merge to `main`.
- Reporting requirements: Report test results, any RED to GREEN repair, changed files, verified protections, known bypass limitations, worktree and remote state, and remaining operator acceptance and promotion steps.
- Open questions: Operator acceptance and promotion remain separate decisions after verification and review.

## Closure verification results

Observed after implementation at `87487d1e841227a9e6505adce30aa8c56afb9397`:

- `bash scripts/tests/command-gate-test.sh`: Initial closure run PASS, `137` passed and `0` failed. A coverage review then identified that destructive later pipeline segments and generic wrappers were not named explicitly; three focused fixtures were added and the full suite rerun as recorded below.
- `bash scripts/tests/command-gate-test.sh` after coverage additions: PASS, `140` passed and `0` failed.
- `bash scripts/verify-structure.sh --template`: PASS, required template structure.
- `bash scripts/verify-operating-model.sh`: PASS, operating-model documentation contract.
- `bash -n scripts/command-gate.sh`: PASS.
- `bash -n scripts/tests/command-gate-test.sh`: PASS.
- `git diff --check`: PASS.
- Worktree before adding this evidence: clean; afterward only this new evidence card was untracked.

The fixture run verified ALLOW, REVIEW, and BLOCK outcomes; protected Git mutations; shell, interpreter, environment, BusyBox, and generic wrapper bypasses; destructive delete and refspec forms; a destructive later pipeline token segment; unchanged argv execution for an approved REVIEW; redacted argument logging; and mutation-test sensitivity. The implementation passed before and after the coverage additions, so there is no RED to GREEN repair in this closure round.

Known limitation: REVIEW execution requires a non-empty decision ID and reason and preserves the supplied argv array, but the standalone wrapper cannot authenticate the operator or independently compare argv with an external approval record. Exact argv scope therefore remains an operator/runner integration contract, not cryptographically or externally authenticated enforcement inside this repository.

This evidence makes the frontier ready for operator review. It does not record `operator_accepted`, `LANDED`, `CLOSED`, or `PROMOTED`; those remain later operator-controlled actions.
