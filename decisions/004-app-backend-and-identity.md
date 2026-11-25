# ADR-004: App backend and identity for the estate

- **Status:** Accepted (2026-11-25)
- **Related:** [ADR-008](008-container-images.md), [ADR-010](010-one-host-docker-compose.md) (its edge exception, point 7), [ADR-022](022-home-route-for-access-only-apps.md), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (points 2, 5 and 6 do not apply to its stories), [ADR-038](038-a-childs-device-is-paired-once-by-a-parent.md) (extends point 3: a child's paired device)

## Context

Two app repos plan a backend and have left the same questions open:
`khe-study` for single-learner sync in Phase 2 of its
[roadmap](https://github.com/khelias/khe-study/blob/main/ROADMAP.md), and
`khe-trips` for co-editing, where invited friends edit a trip, which a JSON
file in git cannot support with more than one writer. Deciding these twice
is how the estate ends up with two auth stacks and two ways of running
Postgres. Both repos are also reference projects, so the choice is partly
about what the code shows.

What already exists: Postgres on the homelab runs as one container per app;
the homelab backs up each listed database offsite and restores a dump into
a throwaway container on a schedule; Cloudflare Access fronts the private
apps and gives every request a signed identity (JWT)
([ADR-022](022-home-route-for-access-only-apps.md)); a self-hosted identity
provider waits on a RAM upgrade of the homelab host. The two backends pull
toward different languages: a relational core with roles and jobs for
trips, a thin sync layer beside a TypeScript game engine for study.

## Decision

1. **`khe-trips` builds the first backend, `khe-study` reuses it as a
   pattern.** Trips has the real multi-user need (per-trip roles,
   concurrent edits, invitations); study's Phase 2 is single-learner sync
   with last-write-wins. The harder case sets the pattern.
2. **Postgres, one container per app,** on the homelab, added to the backup
   job in the same change that adds the database. Schema changes go
   through versioned migrations checked into the app repo.
3. **Authentication stays at the edge and is swappable.** The app does not
   store passwords or run its own login. It verifies a JWT from a
   configured issuer against that issuer's JWKS and maps the subject and
   email to its own user row. The first issuer is Cloudflare Access with
   an email one-time PIN, enough for invited friends. An app that admits
   invited people gets an Access application of its own, with its own
   allowlist and without the shared policy's country rule (ADR-022 point
   4). After the RAM upgrade the issuer can be Authentik over OIDC, and the
   swap is configuration, not code.
4. **Authorization is the app's job.** Who may see or change what is data
   in the app's own database (for trips: membership per trip with owner,
   editor and viewer roles). The edge answers "who is this", never "may
   they do this".
5. **One write path per app.** Every change, from any source (a person, an
   importer, an AI assistant), goes through the same API and lands in a
   revision log that records who changed what and when. Automated sources
   write proposals that a person accepts; they never write directly.
6. **Operational baseline from day one:** a health endpoint in the uptime
   monitor, structured logs in the log pipeline, and a restore test: the
   app's database joins the restore check in the same change that creates
   it, and one passing run comes before any data that is not the family's
   own enters it.
7. **One backend language per app, on one shared platform.** Each app picks
   the language that fits it and records the choice in its own docs. What
   stays shared, so a second backend is not a second platform: the
   container platform of [ADR-008](008-container-images.md), the JWT
   contract of point 3, and OpenAPI as the API contract. The sales site in
   ADR-010's exception runs as a Cloudflare Worker, not on the container
   platform, and keeps no database of its own; point 6 applies to it when
   it deploys.

## Alternatives considered

- **Each app decides on its own.** Two auth stacks and two ways of running
  Postgres, for no gain.
- **Login in the app.** Passwords and sessions to store and protect, where
  the edge already gives a verified identity.
- **A self-hosted identity provider now.** Waits on the RAM upgrade; point
  3 keeps the swap to configuration when it comes.
- **One language for every backend.** Either a heavy runtime for a thin
  sync layer, or hand-built what a framework gives a relational core.

## Consequences

- `khe-study`'s open "auth provider" question is answered by point 3.
- The `khe-trips` scope changes from "no accounts" to invite-only
  accounts. Open sign-up and a public hosted service stay out of scope.
- Friends' names and emails will live on the homelab. That is why the
  restore test in point 6 is a precondition and not a nice-to-have.
- The shared Access policy has a country rule a friend abroad cannot
  pass, so a co-edited app needs its own policy.
- Two languages mean two dependency trees and two CVE streams to keep
  current; revisit point 7 if that costs more than the fit is worth.
