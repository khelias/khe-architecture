# KHE estate

Canonical navigation index for the KHE estate. It lives in the public
[`khe-architecture`](https://github.com/khelias/khe-architecture) repo,
beside the estate's decisions in [`decisions/`](decisions/).

Loaded automatically as workspace-level context for Claude Code working
in `<KHE_ROOT>/`, the checkout of the [`khe-workspace`](https://github.com/khelias/khe-workspace)
workspace repo: its `CLAUDE.md` `@`-imports this file from
`repos/khe-architecture/ESTATE.md`. Codex and other agents.md-only tools do not see
this file (the spec does not support `@`-imports); they read
`<KHE_ROOT>/AGENTS.md` (personal prefs), which points here by path. When in doubt
about which repo owns what, start here.

## Product apps

| Repo | Visibility | Purpose | Lives at |
|------|------------|---------|----------|
| [khe-study](https://github.com/khelias/khe-study) | public | Educational web game platform; small games for the Estonian curriculum. | [games.khe.ee/study](https://games.khe.ee/study) - static via homelab |
| [khe-ai-adventure](https://github.com/khelias/khe-ai-adventure) | public | AI-narrated pass-the-phone party game (3-6 players). | [games.khe.ee/adventure](https://games.khe.ee/adventure) - `adventure-web` + `adventure-proxy` containers in the homelab games stack, images from GHCR ([ADR-008](decisions/008-container-images.md)) |
| [khe-trips](https://github.com/khelias/khe-trips) | private | Private family trip atlas. | trips.khe.ee - homelab, behind Cloudflare Access; shared trips at `khe.ee/r/<slug>/` via the landing container |

## Foundations

| Repo | Visibility | Purpose | Lives at |
|------|------------|---------|----------|
| [khe-sites](https://github.com/khelias/khe-sites) | public | Static source for the public KHE web presence: landing + games hub + lab atlas. | [khe.ee](https://khe.ee), [games.khe.ee](https://games.khe.ee) - static via homelab |
| [khe-homelab](https://github.com/khelias/khe-homelab) | public | Self-hosted Proxmox + Docker Compose infra: core, media, apps, home and observability stacks. | The homelab itself (Proxmox VM at home, Cloudflare Tunnel for public services) |

## Meta layer

| Repo | Visibility | Purpose | Lives at |
|------|------------|---------|----------|
| [khe-workspace](https://github.com/khelias/khe-workspace) | public | Workspace root (formerly `khe`, before that `khe-ai-rules`): personal AI agent configuration (AGENTS.md, CLAUDE.md, hooks, settings) and `repos/repos.yaml`, the list of repos cloned into `repos/`. | `<KHE_ROOT>` itself; every repo in `repos/repos.yaml` (every repo here except khe-workspace itself and khelias) is cloned into `<KHE_ROOT>/repos/<name>/` by `scripts/workspace.sh clone` |
| [khelias](https://github.com/khelias/khelias) | public | GitHub profile README. | [github.com/khelias](https://github.com/khelias) - rendered on profile page |
| [khe-architecture](https://github.com/khelias/khe-architecture) | public | The estate's architecture decisions and this estate index ([ADR-012](decisions/012-estate-architecture-is-public.md)). | [github.com/khelias/khe-architecture](https://github.com/khelias/khe-architecture) |
| [khe-meta](https://github.com/khelias/khe-meta) | private | Cross-repo work: the estate-level roadmap, the working plans, and `house/` - the Home Assistant and HVAC documentation too identifying for the public `khe-homelab`. | [github.com/khelias/khe-meta](https://github.com/khelias/khe-meta) |
| [ha-estfeed](https://github.com/khelias/ha-estfeed) | public (fork) | Fork of tehisain/ha-estfeed: Home Assistant integration for Elering Estfeed meter data, with the day/night grid tariff, cost sensors, the resume-point and NPS partial-hour fixes and the hourly price statistic. A permanent fork: upstream is merged in periodically, and only the two bug fixes are proposed upstream (#3, #5). Installed in the homelab HA via HACS as a custom repository. | HACS in `khe-homelab` Home Assistant |

## Where things deploy

- **Homelab** (Proxmox VM at home, behind Cloudflare Tunnel) hosts the public `khe.ee`, `games.khe.ee` and its sub-paths (`/study`, `/adventure`), `pages.khe.ee` and the khe-trips share sites at `khe.ee/r/<slug>/` (landing container); `trips.khe.ee`, `dash.khe.ee` and `draft.khe.ee` behind Cloudflare Access; `photos.khe.ee`, `vault.khe.ee` and `status.khe.ee` on the tunnel behind their own app login (the status page itself is public); and the LAN-only services in `khe-homelab/services/` (Home Assistant, AdGuard, NPM admin, Grafana). The tunnel and Access tables are in `khe-homelab/infrastructure/cloudflare.md`.
- **GHCR** (`ghcr.io/khelias/*`, public packages) holds the images the estate builds in CI; `khe-homelab` pins them by digest and each app's CI moves its pins through an auto-merging PR ([ADR-008](decisions/008-container-images.md)). `khe-ai-adventure` is the first app on it.
- **GitHub** renders `khelias/khelias` on the profile page.
- **No third-party hosting** is currently in use. Adding a Cloudflare Pages or Netlify fallback for the static apps is on the private khe-meta roadmap.

## Adding a repo

Besides this index and `repos/repos.yaml`:

- **Naming:** `khe-workspace` was `khe` until 2026-10-07, and GitHub redirects the old name only while no repo takes it. Never give `khe` or `khe-ai-rules` to a new repo.
- **Public:** the default-branch ruleset from [ADR-006](decisions/006-branch-protection.md) (deletion + non-fast-forward, no bypass), plus the CI status check if it deploys.
- **Public with a homelab runner:** fork PR approval `all_external_contributors` (ADR-006).
- **Renovate:** `renovate.json` alone does nothing. The repo also has to be added to the Renovate app's repository selection at <https://github.com/settings/installations>. The Dependency Dashboard issue appearing is the proof that it runs.
- **Ships a container image:** a pin App of its own (like `khe-adventure-pins`: Contents and Pull requests write, installed on `khe-homelab` only), a `homelab-pin` environment limited to `main` holding its secrets, one `PIN_APPS` line in homelab's `validate.yml` and one `source_repo` entry in `scripts/verify-estate-pins.sh` ([ADR-008](decisions/008-container-images.md)). The first publish creates each GHCR package private; make it public once in its package settings. A private repo has no attestations on GitHub Free, so decide the pin check first.
- **Private:** GitHub Free has no auto-merge there. `gh api -X PATCH -F allow_auto_merge=true` answers 200 and leaves the field `false`, so do not spend time on it. Renovate's `platformAutomerge` falls back to its own merge.

## Per-repo roadmaps

When the private khe-meta roadmap points at a per-repo phase,
the source of truth is in that repo:

- [khe-study/ROADMAP.md](https://github.com/khelias/khe-study/blob/main/ROADMAP.md) - bounded contexts, learning platform phases 0-6
- [khe-ai-adventure/ROADMAP.md](https://github.com/khelias/khe-ai-adventure/blob/main/ROADMAP.md) - playtest gates, model strategy, prompt work
- [khe-homelab/ROADMAP.md](https://github.com/khelias/khe-homelab/blob/main/ROADMAP.md) - house automation, offsite backup, DR, hardware, service wishlist
- [khe-trips/ROADMAP.md](https://github.com/khelias/khe-trips/blob/main/ROADMAP.md) - scope decision, trip sharing, backend and co-editing, template publication
- khe-workspace, khe-sites, khelias, ha-estfeed - no standalone ROADMAP.md (covered inline or in the private khe-meta roadmap)
