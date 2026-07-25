# Agent command policy

All agent-controlled terminal commands in this repository must be invoked through
`scripts/command-gate.sh`. Use check-only when classification is uncertain:

```text
bash scripts/command-gate.sh --check-only -- <command> <args...>
```

An `ALLOW` result may execute through the wrapper. A `REVIEW` result requires an explicit operator
decision ID, reason, and exact argv scope. A `BLOCK` result must not execute and must be reported.
Agents must not use direct terminal access, nested shells, command reconstruction, or another tool
to bypass the decision.

This is automatic pre-execution enforcement only when the wrapper is used. It is not global
terminal interception. An adopting project must connect its agent runner or terminal adapter to
the wrapper—and restrict alternate execution paths—for full technical enforcement. The standalone
wrapper checks that REVIEW metadata is present but cannot authenticate who supplied it; agents must
never invent or reuse an operator decision outside its recorded argv scope.
