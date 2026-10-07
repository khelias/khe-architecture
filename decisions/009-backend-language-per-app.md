# ADR-009: One backend language per app: Java for khe-trips, TypeScript for khe-study

- **Status:** Accepted (2026-09-28)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-008](008-container-images.md)

## Context

Two app repos plan a backend: `khe-trips` for invite-only co-editing of
trips, `khe-study` for syncing a learner's progress. How those backends store
data and authenticate is [ADR-004](004-app-backend-and-identity.md); which
language each is written in was left open there, and the two apps pull in
different directions.

The `khe-trips` backend has a relational core (trips, days, members,
invitations), per-row optimistic locking for concurrent edits, a revision
log of who changed what, per-trip roles, and server-side jobs (weather and
route, recomputed when a place or the day order changes). The `khe-study`
backend is single-learner sync with last-write-wins, a thin layer over
storage, next to a frontend game engine written in TypeScript.

Both repos are meant to be reference projects, so the choice is partly about
what the code shows, not only about what ships fastest.

## Decision

One language per app, on one shared platform:

- **`khe-trips`: Java with Spring Boot.** Relational data, optimistic
  locking, roles and scheduled jobs are Spring's home ground, and Spring
  Security's resource server verifies an issuer's JWT against its JWKS by
  configuration alone, which is ADR-004 point 3 with no auth code of its
  own. It is also our day-to-day professional stack, so the repo shows
  Spring as it is used in production work.
- **`khe-study`: TypeScript on Node.** The server can share the frontend
  game engine as-is, for example to validate a change to a learner's
  in-game wallet with the same code the client runs.

What stays shared, so a second backend is not a second platform:

- the container platform of [ADR-008](008-container-images.md): images built
  in CI, published to GHCR, pinned in `khe-homelab`, with its runtime
  convention for backends;
- the JWT contract proposed in ADR-004 point 3;
- OpenAPI as the API contract in both apps.

## Alternatives considered

- **One language for both backends.** Java for both would give `khe-study` a
  heavy runtime for a thin sync layer and lose the shared engine code.
  TypeScript for both would rebuild in hand what Spring gives `khe-trips`
  for its relational and concurrency needs.

## Consequences

- Two dependency trees for Renovate to keep current and two CVE streams to
  watch, Maven and npm. This is the accepted cost.
- The JVM is a new runtime on the homelab. Measure the VM's memory headroom
  before the `khe-trips` backend picks its heap and container memory limits.
- This answers the backend-language question `khe-study`'s roadmap left open
  for its Phase 2; its auth provider follows ADR-004.
- Revisit if one of the backends is dropped, or if keeping two runtimes
  current costs more than the reasons above are worth.
