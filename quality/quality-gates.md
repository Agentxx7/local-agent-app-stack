# Quality gates

Choose the gates relevant to the change and record evidence or `NOT APPLICABLE` with a reason.
These are review prompts, not automated enforcement.

- Scope: Only approved paths and outcomes changed.
- Build: Required build targets completed.
- Tests: Relevant tests completed and failures are disclosed.
- Production-path evidence: Tests or manual checks reach the path they claim to verify.
- Dependencies: Additions have purpose, owner, version, and verification.
- Secrets: No credentials, private paths, or operator data entered version control.
- State: Sources of truth, writers, migration, and cleanup are accounted for.
- Process cleanup: Created processes have identity, ownership, timeout, and cleanup evidence.
- Documentation: Behaviour, decisions, and limitations are current.
- Git status: Commit, push synchronization, and worktree state are reported separately.

Risk and complexity may justify additional verification, but a separate risk or complexity review
is not mandatory for every card. The operator chooses applicable gates and decides acceptance.
