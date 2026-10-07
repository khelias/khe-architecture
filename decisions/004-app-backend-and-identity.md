# ADR-004: App backend and identity for the estate

- **Status:** Proposed (2026-09-23)
- **Related:** [ADR-009](009-backend-language-per-app.md), [ADR-011](011-cloudflare-tunnel-and-access-edge.md)

## Context

Two app repos plan a backend, and both have left the same questions open:

- `khe-study` plans backend, auth and sync for Phase 2 of its
  [roadmap](https://github.com/khelias/khe-study/blob/main/ROADMAP.md), and
  lists the backend language and the auth provider as open decisions.
- `khe-trips` needs the same two answers for co-editing: friends invited to
  a trip should be able to edit it, which a JSON file in git cannot support
  with more than one writer.

Deciding these twice, separately, is how the estate ends up with two auth
stacks and two ways of running Postgres. Both repos are also meant to be
reference projects, so the choice is partly about what the code shows, not
only about what ships fastest.

What already exists and constrains the answer:

- Postgres on the homelab runs as one container per app; today the only one
  belongs to the photo service.
- The homelab's backup dumps each listed database nightly and ships it
  offsite with restic to Cloudflare R2, and a scheduled job restores a dump
  from R2 into a throwaway container every week.
- Cloudflare Access already fronts the private apps with an email allowlist,
  and it gives every request a signed identity (JWT)
  ([ADR-011](011-cloudflare-tunnel-and-access-edge.md)).
- A self-hosted identity provider (Authentik or Authelia) waits on a RAM
  upgrade of the homelab host.
- The only backend today is the adventure game's AI proxy (Node, Express),
  which holds no data and has no users.

## Decision

1. **`khe-trips` builds the first backend, `khe-study` reuses it as a
   pattern.** Trips has the real multi-user need (per-trip roles, concurrent
   edits, invitations); study's Phase 2 is single-learner sync with
   last-write-wins. The harder case sets the pattern.

2. **Postgres, one container per app,** on the homelab, added to the backup
   job in the same change that adds the database. Schema changes go through
   versioned migrations checked into the app repo.

3. **Authentication stays at the edge and is swappable.** The app does not
   store passwords or run its own login. It verifies a JWT from a configured
   issuer against that issuer's JWKS and maps the subject and email to its own
   user row. Today the issuer is Cloudflare Access (email one-time PIN); after
   the RAM upgrade it can be Authentik over OIDC, and the swap is
   configuration, not code.

4. **Authorization is the app's job.** Who may see or change what is data in
   the app's own database (for trips: membership per trip with `owner`,
   `editor`, `viewer`). The edge answers "who is this", never "may they do
   this".

5. **One write path per app.** Every change, from any source (a person, an
   importer, an AI assistant), goes through the same API and lands in a
   revision log that records who changed what and when. Automated sources
   write proposals that a person accepts; they never write directly.

6. **Operational baseline from day one:** a health endpoint in the uptime
   monitor, structured logs picked up by the log pipeline, and one tested
   restore of the app's dump before any data that is not the family's own
   enters it.

The backend language per app is decided in
[ADR-009](009-backend-language-per-app.md).

## Alternatives considered

- **Each app decides on its own.** Two auth stacks and two ways of running
  Postgres, for no gain.
- **Login in the app.** Passwords and sessions to store and protect, where
  the edge already gives a verified identity.
- **A self-hosted identity provider now.** Waits on the RAM upgrade; point 3
  keeps the swap to configuration when it comes.

## Consequences

- `khe-study`'s open "auth provider" question is answered once this ADR is
  accepted.
- The `khe-trips` scope changes from "no accounts" to invite-only accounts.
  Open sign-up and a public hosted service stay out of scope.
- Friends' names and emails will live on the homelab. That is why the restore
  test in point 6 is a precondition and not a nice-to-have.
- The shared Access policy has a location rule a friend abroad cannot pass,
  so a co-edited app needs its own policy.
