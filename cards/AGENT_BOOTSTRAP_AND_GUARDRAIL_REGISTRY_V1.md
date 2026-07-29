# Task: Agent bootstrap and guardrail registry V1

- Card ID: `AGENT_BOOTSTRAP_AND_GUARDRAIL_REGISTRY_V1`
- Base commit: `88fbf69ed75b98893f18a70ce539e4637c83760b`
- Work branch: `work/AGENT_BOOTSTRAP_AND_GUARDRAIL_REGISTRY_V1`
- Goal: Make the technology-neutral skeleton executable at agent startup through a registry,
  fail-closed bootstrap, ignored session receipt, command-gate binding, read-only audit mode, and a
  single required-guardrail verification runner.
- Prohibited changes: Product or language-specific checks, agent/model routing, debt queues, asset
  cleanup, process lifecycle attestation, source-of-truth automation, host branch protection, or
  automatic promotion.
- Initial RED: At baseline, `bash scripts/agent-start.sh` exited `127` because the script did not
  exist. Decision: `APPROVE_AGENT_BOOTSTRAP_FRONTIER_COMMANDS_006`.
- Fixture RED: The first integrated fixture run reported `6` passed and `7` failed because the
  harness resolved fixture paths before its local name variable was assigned under `set -u`.
- Fixture GREEN: After the bounded harness fix, all `11` bootstrap scenarios passed.
- Registry uniqueness RED: Duplicate guardrail IDs, duplicate adapter+arguments+scope tuples,
  unknown levels, and unknown lifecycle values initially passed silently (`15` passed, `4` failed).
- Registry uniqueness GREEN: Entry IDs and effective check tuples are unique; level and lifecycle
  values are enumerated; missing/non-executable adapters fail closed; advisory entries parse but do
  not execute as required; distinct adapter reuse is accepted when arguments or scope differ.
- `operator_accepted = true`
- Operator acceptance evidence: bootstrap/registry/session `20/20` PASS; command-gate `140/140`
  PASS; registry verify, structure, operating model, Bash syntax, read-only startup, and
  `git diff --check` PASS. No separate decision ID was supplied with the acceptance message.
- Promotion: Not performed.
