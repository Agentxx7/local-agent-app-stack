# Cards

Lightweight work descriptions and status reports live here. The operating model makes the card-based workflow mandatory: each implementation frontier is owned by one card, created on an isolated `work/<card-id>` branch from verified `main`, and promoted only by operator decision.

Use these templates for every frontier:

- `cards/task-card-template.md` — defines a bounded card, including RED evidence, verification, and stop conditions.
- `cards/status-report-template.md` — reports actual status, evidence, and remaining gaps.

The skeleton does not define an automated approval pipeline, reviewer role, or automated closure process. Those remain operator or host responsibilities.

For the full adoption workflow, see `docs/adopting-the-template.md`.
