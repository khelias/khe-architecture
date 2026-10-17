# ADR-013: A public demo of the trip atlas at khe.ee/trips/ shows only trips that are over

- **Status:** Accepted (2026-10-17)
- **Related:** [ADR-011](011-cloudflare-tunnel-and-access-edge.md), [ADR-004](004-app-backend-and-identity.md), [ADR-001](001-repo-per-product.md)

## Context

[`khe-trips`](https://github.com/khelias/khe-trips) is the family's private
trip atlas: a world map and timeline of every trip, and one roadbook page per
trip. The atlas at `trips.khe.ee` sits behind Cloudflare Access
([ADR-011](011-cloudflare-tunnel-and-access-edge.md)), the repo is private,
and its roadmap said that no phase makes the atlas public. A single trip can
already be shared as an unlisted link at `khe.ee/r/<slug>/`: one trip, the
planning layer removed, built and served apart from the atlas.

We want the atlas on the public `khe.ee` landing the way the 3D house demo
is there: something a visitor can open, not only read about. The atlas is
also a record of where and when the family travelled, and a trip still
ahead says when the house is empty. Putting real places and dates on a
public, linked page is hard to take back once it has been copied, and the
work spans three repos: `khe-trips` builds it, `khe-homelab` serves it and
`khe-sites` links to it.

## Decision

1. **A separate demo build of the atlas is public at `khe.ee/trips/`.**
   `khe-trips` builds it from a document of its own, `khe-homelab`'s landing
   container serves it beside the `/r/` share sites, and `khe-sites` links
   it from the landing page.
2. **The demo shows only trips that are over.** A trip that is upcoming or
   under way is not in it at all, on the map, in the timeline or in the
   bundle.
3. **One trip opens; the rest are locked.** The open trip is exactly its
   share build (planning layer removed, the same allowlist). For every
   other trip the demo carries only its short title, its place on the map
   and its start date; nothing else about it reaches the bundle.
4. **The demo is not indexed.** `noindex` in the page and an
   `X-Robots-Tag` header as on `/r/`, no sitemap entry, and no
   `robots.txt` disallow, since a crawler that may not fetch the page never
   sees its `noindex`.
5. **What stays private does not change.** `trips.khe.ee` stays behind
   Access, the repo stays private, and planning data and upcoming trips
   never leave it.

The rule for later work: **the public demo shows only trips that are over,
and only `shortTitle`, `coords` and `startDate` for trips that do not
open.** The demo build checks its own output against it.

## Alternatives considered

- **Invented demo trips** (the roadmap's template demo data): nothing real
  leaves the repo, but it is the larger piece of work that the template
  phase owns, and a made-up atlas does not show what the app is for.
- **The demo behind Access:** private, but then it is not something a
  visitor to `khe.ee` can open, which is the point.
- **Only the `/r/` link:** already public by link, but unlisted, and it
  shows one trip without the map and timeline the atlas is built around.
- **Upcoming trips as locked pins as well:** a fuller map, but a public
  page would then say when the house is empty.

## Consequences

- The family's past travel (which countries, roughly when) is public and
  linked. That is accepted for trips that are over, and a trip enters the
  demo only once it is.
- `khe-trips` keeps a third build mode beside the atlas and the share
  builds, and the demo's leak check (other trips' prose, anything naming a
  trip not over, unused photos, the editor) is part of its deploy.
- `khe-homelab`'s landing container gains a bind mount and a route, served
  like `/r/`: no edge cache, so a fix is not stuck at the edge.
- Revisit if the template ships invented demo data that can replace the
  real trips, or if a locked pin turns out to say more than intended.
