# ADR-046: The khe-trips backend is TypeScript on Node, running the client's own core

- **Status:** Accepted (2026-11-18)
- **Related:** [ADR-009](009-backend-language-per-app.md) (replaces its khe-trips point; the khe-study point stands), [ADR-004](004-app-backend-and-identity.md), [ADR-008](008-container-images.md), [ADR-047](047-trips-public-code-private-data.md)

## Context

[ADR-009](009-backend-language-per-app.md) gave the
[khe-trips](https://github.com/khelias/khe-trips) backend Java with Spring
Boot, because its first design was an online editor over a relational core:
per-row optimistic locking, roles and scheduled jobs, which Spring handles by
configuration.

The app's direction has changed since. It is used almost only on phones,
often without signal, so it has to open and be edited offline. That makes
the server a second runner of the client's work: a phone applies a named
operation to its own copy at once, queues it, and the server re-runs the
same operation against the authoritative copy when the phone is back online.
The server also builds the share and demo exports with the share filter.

Everything the server would run already exists in the client, in TypeScript
and free of any framework: the trip schema, the joins between days and the
registers, the share filter and its leak checks, all tested. In Java each of
these would be a second implementation that has to agree with the first to
the field. Where they disagree, an operation accepted on the phone is refused
by the server, or the export lets through a field the client's filter drops.
The first loses a family member's edit, the second leaks planning data.

ADR-009 already chose TypeScript for khe-study for this reason, so the
server can share the client's engine.

## Decision

1. **The khe-trips backend is TypeScript on Node**, on Postgres as
   [ADR-004](004-app-backend-and-identity.md) point 2 sets out.
2. **One core, run unchanged on both sides.** The schema, the operations,
   the joins and the share filter live in one package that the web client
   and the server import. The server is authoritative: it re-runs each
   queued operation and its validation, and never trusts a client's result.
3. **Identity is unchanged.** The server verifies the edge's JWT against
   the issuer's JWKS with a maintained library, as ADR-004 point 3 requires,
   and keeps no login of its own.
4. **The platform is unchanged.** The server ships as a CI-built image on
   GHCR, pinned in khe-homelab ([ADR-008](008-container-images.md)), and
   its HTTP API is described in OpenAPI, the contract ADR-009 shares
   between the apps.

## Alternatives considered

- **Java with Spring, the core ported.** Two implementations of the
  schema, the operations and the share filter, kept in step by tests on both
  sides. Every schema change lands twice, and a drift between them loses
  edits or leaks data, the two failures the design exists to prevent.
- **Java with Spring, the server storing operations without running them.**
  The server could no longer refuse an operation that breaks a trip, resolve
  a conflict or build an export, so it would not be authoritative.
- **Java generated from the TypeScript schema.** Covers types, not the
  operations' logic or the share filter, which are the parts that must
  agree.

## Consequences

- Both planned backends are now TypeScript, so the estate runs no JVM and
  keeps one dependency stream for its servers. ADR-009's accepted cost of
  two (Maven beside npm) and its memory measurement for a heap no longer
  apply to khe-trips.
- What Spring gave by configuration is written or chosen here: JWT
  verification through a library, conflict detection through revisions in
  the data, jobs as small scheduled tasks of the server.
- The repo no longer shows the Spring stack used in professional work. That
  is accepted: shared code between client and server is the thing the repo
  now has to show.
- Revisit if the core stops being shared, for example if the client moves
  to a language the server cannot run.
