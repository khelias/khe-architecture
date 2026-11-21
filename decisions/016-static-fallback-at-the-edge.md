# ADR-016: A Cloudflare Worker serves a copy of the static sites when the homelab is down

- **Status:** Accepted (2026-11-21)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-010](010-one-host-docker-compose.md), [ADR-022](022-home-route-for-access-only-apps.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (the edge copy leaves out the stories audio), [ADR-041](041-installed-apps-stay-on-their-paths-with-a-worker-each.md) (no worker from the edge copy)

## Context

Every public KHE frontend is served from the one homelab VM
([ADR-010](010-one-host-docker-compose.md)) through Cloudflare Tunnel
([ADR-022](022-home-route-for-access-only-apps.md)): the `khe.ee` landing
with its pages, trip shares and demo, and the `games.khe.ee` hub with its
games. All of them are static builds. A host outage, a broken deploy or a
stopped tunnel takes them all off the internet, which ADR-010 accepted.

A copy of static files can live at the edge, but it has to answer on the
same hostnames only when the homelab does not. Most static hosts take over
the hostname's DNS record, which points at the tunnel, so failing over to
them needs a paid load balancer. A Worker on a route runs in front of the
existing origin and can serve its own copy only when the origin fails. Its
free quota is per request, and a route can fail open, letting requests go
on to the origin once the quota is spent.

## Decision

How the Worker, its routes, the quota and the staging work is in
khe-homelab's
[Cloudflare doc](https://github.com/khelias/khe-homelab/blob/main/infrastructure/cloudflare.md#workers-routes)
and
[operational notes](https://github.com/khelias/khe-homelab/blob/main/docs/operational-notes.md#edge-fallback).

1. **A Cloudflare Worker with static assets sits in front of `khe.ee` and
   `games.khe.ee`.** It passes the homelab's answer through unchanged and
   serves its copy only when the origin errs, times out or cannot be
   reached. The copy reproduces the served behaviour: SPA fallbacks, hard
   404s, redirects and security headers. Both routes fail open.
2. **`khe-homelab` owns the Worker and mirrors what the homelab serves**,
   not each app deploying a copy of its own. A scheduled job copies the
   served trees as they are and deploys them when they changed. The
   homelab stays primary; the edge is a fallback only.
3. **Private builds are not copied**, first the trip atlas, whose build
   carries the whole private atlas: a third party would become a second
   place that data rests. The copy is reachable only through the two
   routes.
4. **No secret enters the copy.** A file the container writes at start
   from a secret is replaced in the copy by a stub without it, and staging
   fails on a tree that carries one.
5. **API calls, writes and the health path never fall back.** They get the
   origin's answer, failure included, so a frontend sees that its backend
   is down and the uptime monitor sees an outage.

## Alternatives considered

- **Pages behind the same hostname:** a Pages custom domain replaces the
  DNS record the tunnel needs; it works only with Load Balancing.
- **Load Balancing with Pages as the second pool:** health-checked
  failover, but a paid add-on for a family estate.
- **Edge-primary hosting:** the edge serves the static sites always and the
  homelab only the backends. Simpler failover, but the homelab leaves the
  static path, and the self-hosting point of ADR-010 goes with it.
- **Cloudflare Always Online:** free, but it serves crawled HTML snapshots
  only, without the assets the games and the SPAs need.
- **Each app deploying its own Worker:** a token and a copy of the routing
  script per app, and each copy is what its pipeline built rather than what
  the homelab actually serves.

## Consequences

- The one-vendor dependency ADR-022 accepts deepens: Cloudflare now also
  holds a copy of the public sites. A Cloudflare outage still takes them
  down.
- The fallback serves visitors outside the home network only; inside it,
  and over Tailscale, `khe.ee` resolves to the homelab's own proxy.
- A header, redirect or SPA-fallback change in the homelab's web server
  has to be mirrored in the Worker in the same change; a test fails a
  commit on drift.
- A deploy reaches the copy at the next sync, and nothing syncs while the
  homelab is down: the last copy keeps serving. A withdrawn trip share
  stays in the copy until the next sync.
- One more automated writer, the sync, in the estate's register
  ([ADR-007](007-automated-writers.md)).
- Revisit if traffic nears the free quota, if the trips backend changes
  what is private, or if a second host arrives and failover can stay in
  the estate.
