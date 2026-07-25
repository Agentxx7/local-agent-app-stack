# TDD and evidence policy

> Every code card begins with a defined failing proof where practical and ends with evidence from
> the real affected path. Tests guide implementation; evidence and the operator determine
> acceptance.

Use RED, GREEN, REFACTOR, VERIFY, REPORT, OPERATOR DECISION, and PROMOTE for code changes. Record
the initial failure, the reason it is relevant, the passing result, the affected production path,
and the exact commit. Never manufacture a failing unit test when another proof better represents
the behaviour:

| Change | Verifiable prior and final evidence |
|---|---|
| Bug fix | Reproducing regression test |
| Existing unknown code | Characterization test |
| API or database | Integration test against the real path |
| GUI | Automation where practical plus operator verification |
| Audio or TTS | Technical check plus actual listening |
| 3D or visual | Reproducible scene plus operator verification |
| LLM or agent behaviour | Evals, fixtures, traces, and operator assessment |
| Documentation | Contract, link, or structure check plus review |
| Architecture | Constraint and dependency checks plus review evidence |
| Process, state, or cache | Runtime and residue checks |

The adopted project chooses its tools. A green test does not establish relevance to production,
operator acceptance, commit, push, promotion, or release.
