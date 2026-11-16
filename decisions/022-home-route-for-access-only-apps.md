# ADR-022: Public traffic enters only through Cloudflare Tunnel, private apps sit behind Access, with a home route while they have no backend

- **Status:** Accepted (2026-11-16)
- **Supersedes:** [ADR-011](011-cloudflare-tunnel-and-access-edge.md)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-010](010-one-host-docker-compose.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (the stories app's family build)

## Context

[ADR-011](011-cloudflare-tunnel-and-access-edge.md) set up the estate's
edge: no open ports, an outbound Cloudflare Tunnel, and Cloudflare Access
in front of the private apps. One of its consequences was that an app
whose only gate is Access has no route inside the home network, because
Access sees only traffic that comes through Cloudflare.

The private apps without a login of their own (the homelab dashboard, the
trip atlas and the stories app's family build) now have such a route. On
the home network and over Tailscale their hostnames resolve to the
homelab's own reverse proxy instead of Cloudflare. Three things made that
worth it:

- At home nobody types a one-time PIN, on any device.
- The apps keep working at home when the internet line or Cloudflare is
  down.
- Abroad, the Access policy's country rule blocks the family. The homelab
  is not a Tailscale exit node, so Tailscale alone does not carry them
  past it, but over Tailscale the home route opens.

The household accepted that every device on the home network and the
tailnet reads these apps without a login.

A request on the home route carries no Access identity. That costs
nothing while no app reads the identity. It becomes a hole the day a
backend trusts it: [ADR-004](004-app-backend-and-identity.md) point 3 has
the trip atlas's backend verify the Access JWT, and point 5 records who
made each change.

This ADR restates ADR-011, so that one live ADR describes the edge.
Points 1-3 keep their numbers and meaning, so a citation of "ADR-011
point 2" reads as point 2 here.

## Decision

1. **No open ports.** The home router forwards nothing. Public traffic
   reaches the homelab only through an outbound Cloudflare Tunnel, which
   routes each hostname to its container.
2. **Private apps sit behind Cloudflare Access.** An app without a login of
   its own, or one meant only for us (for example `trips.khe.ee`), is
   fronted by an Access application with an email allowlist and a one-time
   PIN. Access gives every request a signed identity (JWT), which is what
   [ADR-004](004-app-backend-and-identity.md) point 3 has an app backend
   verify.
3. **Family services with their own login** are on the tunnel without
   Access, so the family can use them from their own apps.
4. **A private app may have a home route while it has no backend that
   reads the edge identity.** The home network's DNS then points its
   hostname at the homelab's reverse proxy, and the home network and the
   tailnet reach it without Access. The change that adds a backend
   reading the identity removes the home route in the same change. For the
   trip atlas that is the backend's first slice, and the same change moves
   `trips.khe.ee` from the shared Access policy to an Access application of
   its own without the country rule, so the family abroad is not locked out
   before the invitations arrive. That brings the application of its own in
   ADR-004 point 3 forward; ADR-004 does not forbid it earlier. A home route
   for an app with a backend may return only when an issuer that works off
   the Cloudflare path (Authentik over OIDC, ADR-004 point 3) replaces
   Access.

The tool comparison (Tailscale Funnel, a self-hosted tunnel on a rented
server, plain port forwarding) is in `khe-homelab`'s
[service choices](https://github.com/khelias/khe-homelab/blob/main/docs/service-choices.md),
and the live routes, home routes and policies in its
[Cloudflare configuration](https://github.com/khelias/khe-homelab/blob/main/infrastructure/cloudflare.md).

## Alternatives considered

- **An Access policy without the country rule, instead of a home route.**
  It solves abroad, but keeps the PIN at home and the dependency on
  Cloudflare when the line is down.
- **A Tailscale exit node at home.** It carries the family past the
  country rule abroad, but sends all of their traffic home and still needs
  Cloudflare.
- **Keeping the home route once a backend exists, and treating its
  requests as family.** It fails open: any device on the home network
  could write, and the revision log of ADR-004 point 5 would lose who made
  the change.
- **Keeping the home route and verifying the Access cookie on it.** The
  `CF_Authorization` cookie expires and cannot be renewed there, because
  the Access login callback runs at the Cloudflare edge.

## Consequences

- The home connection exposes nothing to scan, and Cloudflare's edge absorbs
  floods and bot traffic before they reach the tunnel.
- A private app needs no login code of its own, and an app backend gets a
  verified identity for free, on the Cloudflare path only.
- The estate depends on one vendor for DNS, edge certificates, the tunnel
  and authentication. If Cloudflare is down or changes its free tier, the
  public estate is unreachable from outside the home network; the apps
  with a home route still open at home and over Tailscale.
- On a home route the gate is being on the home network or the tailnet,
  not who you are.
- An app's first backend slice carries one more step: removing its home
  route and, for an app the family uses abroad, an Access application
  without the country rule.
- Revisit if Cloudflare's free-tier terms change in a way that bites home
  use, if the estate needs to work without Cloudflare for resilience, or if
  a self-hosted identity provider replaces Access as the issuer (ADR-004
  makes that swap configuration, and point 4 then allows home routes for
  apps with a backend).
