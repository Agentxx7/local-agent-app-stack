# Quality gates

Choose the gates relevant to the change and record evidence or `NOT APPLICABLE` with a reason.
For implementation, branch isolation and operator-controlled promotion are mandatory gates and
must not be marked `NOT APPLICABLE` for code or product changes. Their project-specific
verification method may vary. Documentation or analysis cards with no implementation may mark
them `NOT APPLICABLE` with a reason. These are review prompts, not automated enforcement.

- Scope: Only approved paths and outcomes changed.
- Branch: Work started from verified `main` on the branch owned by exactly one card.
- RED or prior proof: Expected behaviour first failed correctly, or an appropriate alternative
  proof was recorded.
- Build: Required build targets completed.
- Tests: Relevant tests completed and failures are disclosed.
- Production-path evidence: Tests or manual checks reach the path they claim to verify.
- Dependencies: Additions have purpose, owner, version, and verification.
- Secrets: No credentials, private paths, or operator data entered version control.
- State: Sources of truth, writers, migration, and cleanup are accounted for, including the
  stateless/stateful classification and canonical ownership in `guardrails/state-and-identity-policy.md`
  where a capability is stateful.
- Process cleanup: Created processes have identity, ownership, timeout, and cleanup evidence.
- Command safety: Agent-controlled commands used the gate; REVIEW decisions and BLOCK/bypass
  attempts are reported. Record any execution path not technically connected to the wrapper.
- Documentation: Behaviour, decisions, and limitations are current.
- Git status: Commit, push synchronization, and worktree state are reported separately.
- Promotion: Operator approval precedes merge, and `main` is verified after merge.

Risk and complexity may justify additional verification, but a separate risk or complexity review
is not mandatory for every card. The operator chooses applicable gates and decides acceptance.
