# ADR-016: A Cloudflare Worker serves a copy of the static sites when the homelab is down

- **Status:** Accepted (2026-10-20)
- **Related:** [ADR-010](010-one-host-docker-compose.md), [ADR-011](011-cloudflare-tunnel-and-access-edge.md), [ADR-013](013-trips-public-demo.md), [ADR-007](007-automated-writers.md)

## Context

Every public KHE frontend is served from the one homelab VM
([ADR-010](010-one-host-docker-compose.md)) through Cloudflare Tunnel
([ADR-011](011-cloudflare-tunnel-and-access-edge.md)): the `khe.ee` landing
with its architecture page, 3D house demo, trip share sites and trip demo,
and the `games.khe.ee` hub with the study and adventure games. All of them
are static builds. A host outage, a broken deploy or a stopped tunnel takes
them all off the internet, which ADR-010 accepted as a consequence.

A copy of static files can live at the edge, but it has to answer on the
same hostnames only when the homelab does not:

- A **Cloudflare Pages** custom domain replaces the hostname's DNS record,
  which today points at the tunnel, so Pages and the tunnel cannot both
  answer `khe.ee`. Switching between them on failure needs **Cloudflare
  Load Balancing**, a paid add-on with health checks. Netlify and GitHub
  Pages have the same DNS problem.
- A **Worker on a route** runs in front of the existing origin. Its fetch
  goes to the tunnel; a tunnel with no connector answers 530 and a stopped
  container 502. The Worker can pass the origin's answer through and serve
  its own static assets only when the origin fails.
- Workers Free allows 100,000 invocations a day, and a route-bound Worker is
  invoked on every request. A route can fail open (requests go on to the
  origin once the quota is spent, as if no Worker existed) or closed (an
  error page). Whether the sites' real traffic stays well under the quota is
  checked from the zone analytics before the routes go live, not assumed.

## Decision

1. **A Cloudflare Worker with static assets sits on the routes `khe.ee/*`
   and `games.khe.ee/*`.** It passes the homelab's answer through unchanged
   and serves its copy only when the origin answers 5xx, times out or the
   fetch fails. The copy reproduces the served behaviour: SPA fallbacks,
   hard 404s, redirects and security headers. Both routes fail open.
2. **`khe-homelab` owns the Worker and mirrors what the homelab serves**,
   not each app deploying a copy of its own. An hourly job on the homelab
   copies the served trees, as they are on disk and in the pinned images,
   and deploys them when they changed. The homelab stays primary; the edge
   is a fallback only.
3. **Private builds are not copied**, first `trips.khe.ee`, whose build
   carries the whole private atlas. A third party would become a second
   place that data rests. The copy is reachable only through the two
   routes: the Worker's `workers.dev` hostname and preview URLs stay off.
4. **No secret enters the copy.** A file the container writes at start
   from a secret, such as the adventure frontend's `config.js`, is replaced
   in the copy by a stub without the secret, and the staging fails on a
   tree that carries one.
5. **API calls, non-GET/HEAD requests and the health path never fall
   back.** They get the origin's answer, failure included, so a frontend
   sees that its backend is down and the uptime monitor sees an outage.

## Alternatives considered

- **Pages behind the same hostname:** the DNS conflict above; it works only
  with Load Balancing.
- **Load Balancing with Pages as the second pool:** health-checked
  failover, but a paid add-on for a family estate.
- **Edge-primary hosting:** the edge serves the static sites always and the
  homelab only the backends. Simpler failover, but the homelab leaves the
  static path, and the self-hosting point of ADR-010 goes with it.
- **Cloudflare Always Online:** free, but it serves crawled HTML snapshots
  only, without the assets the games and the SPAs need.
- **Each app deploying its own Worker:** four tokens and four copies of the
  routing script, and each copy is what its pipeline built rather than what
  the homelab actually serves.

## Consequences

- The one-vendor dependency of ADR-011 deepens: Cloudflare now also holds a
  copy of the public sites. A Cloudflare outage still takes them down;
  that risk stays as ADR-011 accepted it.
- The fallback serves visitors outside the home network only. Inside it, and
  over Tailscale, `khe.ee` resolves to the homelab's own proxy and never
  reaches Cloudflare.
- A header, redirect or SPA-fallback change in the homelab's nginx has to
  be mirrored in the Worker's rules in the same change; a test compares the
  headers so drift fails a commit.
- A deploy reaches the copy within an hour, and nothing syncs while the
  homelab is down: the last copy keeps serving. A withdrawn trip share stays
  in the copy until the next sync.
- One more automated writer, the hourly sync, in the estate's register
  ([ADR-007](007-automated-writers.md)).
- Revisit if traffic nears the free quota, if the trips backend changes
  what is private, or if a second host arrives and failover can stay in
  the estate.
