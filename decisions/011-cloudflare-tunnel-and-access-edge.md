# ADR-011: Public traffic enters only through Cloudflare Tunnel, private apps sit behind Cloudflare Access

- **Status:** Accepted (2026-04-13)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-010](010-one-host-docker-compose.md)

## Context

Everything the estate serves runs on one host at home
([ADR-010](010-one-host-docker-compose.md)): public sites and games, family
services with their own login, and a few private apps that have no login of
their own. All of it has to be reachable from the internet without turning a
home connection into an attack surface.

The date above is when this edge was in place by, with the first commit of
[`khe-homelab`](https://github.com/khelias/khe-homelab), not a recorded
decision day. Cloudflare Access in front of the private apps arrived two
days later, on 2026-04-15. The `khe.ee` DNS zone was already on Cloudflare.

## Decision

1. **No open ports.** The home router forwards nothing. Public traffic
   reaches the homelab only through an outbound Cloudflare Tunnel, which
   routes each hostname to its container.
2. **Private apps sit behind Cloudflare Access.** An app without a login of
   its own, or one meant only for us (for example `trips.khe.ee`), is
   fronted by an Access application with an email allowlist and a one-time
   PIN. Access gives every request a signed identity (JWT), which is what
   [ADR-004](004-app-backend-and-identity.md) point 3 proposes an app
   backend verifies.
3. **Family services with their own login** are on the tunnel without
   Access, so the family can use them from their own apps.

The tool comparison (Tailscale Funnel, a self-hosted tunnel on a rented
server, plain port forwarding) is in `khe-homelab`'s
[service choices](https://github.com/khelias/khe-homelab/blob/main/docs/service-choices.md),
and the live routes and policies in its
[Cloudflare configuration](https://github.com/khelias/khe-homelab/blob/main/infrastructure/cloudflare.md).

## Consequences

- The home connection exposes nothing to scan, and Cloudflare's edge absorbs
  floods and bot traffic before they reach the tunnel.
- A private app needs no login code of its own, and an app backend gets a
  verified identity for free.
- The estate depends on one vendor for DNS, edge certificates, the tunnel
  and authentication. If Cloudflare is down or changes its free tier, the
  public estate is unreachable from outside the home network.
- Access sees only traffic that goes through Cloudflare. A route reached
  inside the home network bypasses it, so an app whose only gate is Access
  has no local route; the live routes are in the Cloudflare configuration.
- Revisit if Cloudflare's free-tier terms change in a way that bites home
  use, if the estate needs to work without Cloudflare for resilience, or if
  a self-hosted identity provider replaces Access as the issuer (ADR-004
  makes that swap configuration).
