# Architecture baseline

This skeleton fixes no framework, language, database, provider, hosting platform, or agent
topology. A project must record those choices explicitly with
`templates/architecture-decision.md`.

General constraints:

- dependencies and ownership are explicit;
- each state domain and process family has one source of truth;
- frontend, backend, modules, configuration, database, and tests have clear boundaries;
- optional AI agents and skills do not become hidden runtime authority;
- failures remain observable technical failures;
- process and state lifecycles include deterministic cleanup;
- tests identify the production boundary and version they prove.
