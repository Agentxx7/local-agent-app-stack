# State health

- Canonical state owner, writer policy, schema, and location are known.
- Migrations, backup, restore, and rollback evidence match the active version.
- Cache is never mistaken for durable truth.
- Test state is isolated from operator and production state.
- Rejected or removed features leave no active state remnants.
