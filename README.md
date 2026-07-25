# Local Agent App Stack

A reusable, technology-neutral application project skeleton.

It provides standard locations for frontend, backend, shared modules, configuration, persistence, tests, documentation, agents, skills, health checks, work cards, and project guardrails.

The repository contains structure and templates only. It does not select a programming language, framework, database, AI model, runtime, deployment platform, or application architecture.

## Use as a GitHub template

Mark this repository as a template in GitHub, then choose **Use this template** to create a new
repository. Clone the new repository, complete `PROJECT.md`, record initial decisions in
`ARCHITECTURE.md`, and replace or extend placeholders only when the real project requires it.

## Repository overview

```mermaid
flowchart TD
    P[Application Project]

    P --> F[Frontend]
    P --> B[Backend]
    P --> S[Shared]
    P --> M[Modules]
    P --> C[Configuration]
    P --> D[Database]
    P --> T[Tests]
    P --> DOC[Documentation]

    P --> A[Agents]
    P --> SK[Skills]
    P --> H[Health Checks]
    P --> CA[Work Cards]
    P --> G[Guardrails]
    P --> I[Incidents]
```

## Structure

- `frontend/` — client-facing code and assets after a frontend approach is selected.
- `backend/` — server-side or application-service code after a backend approach is selected.
- `shared/` — contracts or utilities intentionally shared across project areas.
- `modules/` — bounded feature or capability modules.
- `config/` — safe configuration examples and configuration documentation.
- `database/` — persistence definitions and ordered migrations after storage is selected.
- `tests/` — unit, integration, and end-to-end tests.
- `agents/` — optional project-specific agent definitions.
- `skills/` — optional reusable skill packages.
- `health/` — optional health-check definitions.
- `cards/` — lightweight work-card and status-report templates.
- `guardrails/` — project-specific policy templates.
- `incidents/` — incident documentation templates.
- `templates/` — reusable project, architecture, feature, and module documents.
- `docs/` — additional project documentation.
- `scripts/` — project verification and maintenance scripts.
- `.github/workflows/` — automation selected by the adopting project.

## Decisions deferred to each project

The adopting project chooses its programming languages, frontend and backend frameworks,
application boundaries, data store, migration tooling, configuration system, test tools,
deployment platform, observability, security controls, and any AI capabilities.

Agents, skills, and health checks are optional project areas. They may remain unused or be
removed when they do not fit the application.

Run `bash scripts/verify-structure.sh` to check this repository's placeholder structure.
