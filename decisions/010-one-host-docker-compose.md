# ADR-010: One host, one Docker VM, every service a Compose stack

- **Status:** Accepted (2026-04-13)
- **Related:** [ADR-008](008-container-images.md), [ADR-011](011-cloudflare-tunnel-and-access-edge.md)

## Context

The estate runs on hardware at home: one physical machine, for a family of
a few active users, operated by one person in spare time. Everything the
estate serves runs there: the family services, the static sites and the
estate's own apps.

The date above is when this setup was in place by, with the first commit of
[`khe-homelab`](https://github.com/khelias/khe-homelab); it was not recorded
as a decision on a given day. The question it answers came back once the
estate started building its own container images
([ADR-008](008-container-images.md)) and two app backends were planned: is
it time for Kubernetes?

## Decision

One Proxmox host runs one Docker VM, and every service is a Docker Compose
stack in `khe-homelab`, deployed from git by a push to `main`. Kubernetes is
not adopted, neither for the family services nor, for now, for the estate's
own apps.

The tool choices that follow from this, such as Proxmox over other
hypervisors, are compared in `khe-homelab`'s
[service choices](https://github.com/khelias/khe-homelab/blob/main/docs/service-choices.md),
whose first constraint is this decision.

## Alternatives considered

- **Kubernetes for everything.** On one host and one VM a cluster adds no
  resilience: the host is the single point of failure either way. It costs
  RAM that is already short, and it would mean rewriting every Compose stack
  and the deploy around it.
- **A separate small k3s VM for the estate's own apps only** (the adventure
  game, then the `khe-trips` and `khe-study` backends), with Flux image
  automation and signature checks in place of the pin PRs, health-gated
  rollouts and a namespace per app. This is the named next step, not a
  rejected one. The pin model, the guard and the attestation check of
  ADR-008 carry over to it, so nothing built on Compose now is wasted.

## Consequences

- Operations stay small: one VM to back up, patch and rebuild, one deploy
  path, one place to read logs.
- A service that needs a control plane or many companion containers has a
  high bar to clear.
- There is no rolling update or automatic rescheduling: a deploy recreates
  a container, and a host outage takes everything down until the host is
  back.
- Revisit, starting with the apps-only k3s VM, when one of these holds:
  - a second physical host arrives (a Proxmox cluster comes before
    Kubernetes);
  - a third backend of our own runs, and its deploys or migrations hurt on
    Compose;
  - learning Kubernetes becomes a goal in itself, for which an apps-only VM
    is a safe place.
