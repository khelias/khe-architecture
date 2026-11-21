# ADR-022: Public traffic enters only through Cloudflare Tunnel, private apps sit behind Access, with a home route while they have no backend

- **Status:** Accepted (2026-11-21)
- **Supersedes:** [ADR-011](011-cloudflare-tunnel-and-access-edge.md)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-010](010-one-host-docker-compose.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (the stories app's family build), [ADR-038](038-a-childs-device-is-paired-once-by-a-parent.md) (point 4: a home route with paired-device writes)

## Context

ADR-011 set up the estate's edge: no open ports, an outbound Cloudflare
Tunnel, and Cloudflare Access in front of the private apps. Access sees only
traffic that comes through Cloudflare, so an app whose only gate is Access
had no route inside the home network.

The private apps without a login of their own (the homelab dashboard, the
trip atlas and the stories app's family build) now have such a route: on
the home network and over Tailscale their hostnames resolve to the
homelab's own reverse proxy. At home nobody types a one-time PIN, the apps
keep working when the internet line or Cloudflare is down, and abroad,
where the Access policy's country rule blocks the family, the home route
opens over Tailscale. The household accepted that every device on the home
network and the tailnet reads these apps without a login.

A request on the home route carries no Access identity. That costs nothing
while no app reads the identity, and becomes a hole the day a backend
trusts it: [ADR-004](004-app-backend-and-identity.md) point 3 has a backend
verify the Access JWT, and point 5 records who made each change.

This ADR restates ADR-011 so that one live ADR describes the edge. Points
1-3 keep ADR-011's numbers and meaning.

## Decision

1. **No open ports.** The home router forwards nothing. Public traffic
   reaches the homelab only through an outbound Cloudflare Tunnel, which
   routes each hostname to its container.
2. **Private apps sit behind Cloudflare Access.** An app without a login of
   its own, or one meant only for us, is fronted by an Access application
   that lets in a list of people. Access gives every request a signed
   identity (JWT), which is what ADR-004 point 3 has an app backend verify.
3. **Family services with their own login** are on the tunnel without
   Access, so the family can use them from their own apps.
4. **A private app may have a home route while it has no backend that
   reads the edge identity.** The home network and the tailnet then reach
   it through the homelab's reverse proxy, without Access. The change that
   adds a backend reading the identity removes the home route, and for an
   app the family uses abroad gives it an Access application of its own
   without the country rule. A backend that reads no edge identity and
   needs a paired-device credential for every write may keep the route
   ([ADR-038](038-a-childs-device-is-paired-once-by-a-parent.md) point 4).
   A home route for an app whose backend reads the identity may return only
   when an issuer that works off the Cloudflare path replaces Access
   (ADR-004 point 3).

The tool comparison is in khe-homelab's
[service choices](https://github.com/khelias/khe-homelab/blob/main/docs/service-choices.md),
and the live routes, home routes and policies in its
[Cloudflare configuration](https://github.com/khelias/khe-homelab/blob/main/infrastructure/cloudflare.md).

## Alternatives considered

- **An Access policy without the country rule, instead of a home route.**
  It solves abroad, but keeps the PIN at home and the dependency on
  Cloudflare when the line is down.
- **A Tailscale exit node at home.** It carries the family past the
  country rule, but sends all of their traffic home and still needs
  Cloudflare.
- **Keeping the home route once a backend exists, and treating its
  requests as family.** It fails open: any device on the home network could
  write, and the revision log of ADR-004 point 5 would lose who made the
  change.
- **Verifying the Access cookie on the home route.** The cookie expires and
  cannot be renewed there, because the Access login runs at the Cloudflare
  edge.

## Consequences

- The home connection exposes nothing to scan, and Cloudflare's edge
  absorbs floods and bot traffic before they reach the tunnel.
- A private app needs no login code of its own, and a backend gets a
  verified identity for free, on the Cloudflare path only.
- The estate depends on one vendor for DNS, edge certificates, the tunnel
  and authentication. If Cloudflare is down, the public estate is
  unreachable from outside; the apps with a home route still open at home
  and over Tailscale.
- On a home route the gate is being on the home network or the tailnet, not
  who you are.
- Revisit if Cloudflare's free-tier terms change in a way that bites home
  use, or if a self-hosted identity provider replaces Access as the issuer.
