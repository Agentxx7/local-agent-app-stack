# Security Policy

## Reporting a vulnerability

Do **not** publish credentials, tokens, personal data, or exploit details in a public issue or
pull request.

If you believe you have found a security vulnerability in this repository:

1. Prefer **GitHub private vulnerability reporting** if it is enabled on this repository (the
   "Report a vulnerability" option under the repository's Security tab). This provides a
   private channel between you and the maintainers.
2. If private vulnerability reporting is not available or not enabled, open a minimal **public**
   issue that:
   - States that you believe you have found a security issue.
   - Does **not** include exploit details, proof-of-concept code, credentials, or personal data.
   - Asks the maintainers to establish a private contact channel to receive the details.

## Supported scope

- Only the current `main` branch is actively maintained, unless a maintainer states otherwise
  for a specific release or branch.
- There is no guaranteed response time or remediation service-level agreement (SLA) for reported
  issues. Reports are handled on a best-effort basis.

## Scope of this template's guarantees

This repository is a technology-neutral project template. Its command-gate and command-runner
contract (see `guardrails/command-safety-policy.md` and `guardrails/command-runner-contract.md`)
are documentation and optional classification tooling. They do **not** constitute:

- Complete sandboxing of agent or user activity.
- Automatic or guaranteed enforcement of command safety, independent of how an adopting project
  wires its own runner or terminal adapter.

Adopters remain fully responsible for the security of their own:

- Runtime and application code.
- Dependencies and supply chain.
- Host, container, and operating-system configuration.
- Secrets management, network exposure, and any production deployment.

Using this template does not transfer, delegate, or guarantee any of the above security
responsibilities to the maintainers of the upstream template repository.
