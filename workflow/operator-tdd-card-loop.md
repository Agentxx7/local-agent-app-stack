# Operator TDD card loop

1. The operator describes a problem, goal, observation, or agent report to an advising AI.
2. The operator and advisor reason until the next bounded step is clear.
3. The advisor writes a copyable card with goal, allowed scope, prohibited changes, verification,
   stop conditions, and reporting requirements.
4. The operator selects Claude, Codex, Kimi, or another work agent.
5. The agent works only on the isolated branch owned by that card.
6. The agent reports actual status, changes, tests, evidence, uncertainty, and remaining gaps.
7. The operator returns the report to the advisor.
8. They distinguish implemented, tested, verified, operator accepted, committed, pushed, and
   promoted to `main`.
9. The operator decides whether to create a correction or new card, request review, reject the
   work, or approve promotion.
10. After promotion, `main` is verified again and the work branch is closed.

An agent's green checks are evidence, not approval. The next card is based on the actual report,
not an assumed outcome.

## Code-card sequence

- RED: Write or identify a check for the expected behaviour and prove that it fails for the right
  reason where practical.
- GREEN: Make the smallest change that satisfies the check.
- REFACTOR: Improve structure without changing behaviour; keep relevant checks green.
- VERIFY: Run relevant unit, integration, regression, and real-path checks. Inspect scope,
  dependencies, state, processes, and Git status.
- REPORT: Bind results and evidence to the exact commit.
- OPERATOR DECISION: The operator decides whether the evidence supports promotion.
- PROMOTE: Merge approved work, verify `main`, then close the work branch.

For work that cannot reasonably start with a unit test, use the verifiable prior proof defined in
`quality/tdd-and-evidence-policy.md`.

## Continuous improvement

Use verified reports and incidents to expose recurring gaps. With operator approval, turn the
smallest useful lesson into a clearer guardrail, a reusable skill, a regression test, or an updated
health unknown. Each improvement is a new bounded card from verified `main`; it is not silently
added to the current card.
