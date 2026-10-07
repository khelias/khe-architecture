# ADR-001: Repo-per-product, not monorepo

- **Status:** Accepted (2026-05-03)
- **Related:** [ADR-012](012-estate-architecture-is-public.md)

## Context

The estate is the set of repos under
[github.com/khelias](https://github.com/khelias) and the homelab that runs
them. Each product in it started as its own project, in its own repo, long
before there was an estate to organise: `khe-ai-adventure` in August 2025,
`khe-study` in January 2026, then `khe-homelab`, `khe-sites` and `khe-trips`
in April 2026. When the estate got a cross-repo layer, `khe-meta`, the first
question to settle was why six repos, not one. The answer affects every repo
in the estate.

The repos differ in ways a single repo could not hold without one of them
giving way:

- **Visibility.** `khe-trips` and `khe-meta` are private; the rest are
  public. GitHub sets visibility per repo.
- **Deploy target, CI and checks.** Each product deploys on its own path
  (static files on the homelab, container images pinned in `khe-homelab`,
  Compose stacks), runs its own CI, and has its own local check that runs
  before every commit.
- **History.** Each started as its own project, with its own history worth
  keeping.
- **Reference value.** The public repos are meant to stand alone as reference
  projects: a reader should be able to clone one and see the whole of it.

## Decision

One repo per product. A new product gets a new repo, with its own CI, deploy
and check, and an entry in the estate's list of repos in `khe-meta`.
Cross-repo concerns live in `khe-meta`; nothing is shared through a common
source tree.

Deliberate exceptions:

- `khe-sites` holds two sites, `khe.ee` and the `games.khe.ee` launcher, in
  one repo. They share a build and assets, and are deployed as two
  independent sites.
- `khe-meta` holds no product; it is the cross-repo layer.
- The [`khe`](https://github.com/khelias/khe) workspace repo gives an AI
  coding agent one root over all repos, with the repos cloned into it. It
  holds no product code: git, CI, deploys and visibility stay per repo.

## Alternatives considered

- **One monorepo.** One visibility for private and public products, one CI
  for unrelated deploys, and public reference projects that could not be
  cloned on their own.

## Consequences

- Shared versions and shared code have no natural place, which is what
  [ADR-002](002-independent-stacks.md) and
  [ADR-003](003-adventure-proxy-stays-adventure-only.md) settle.
- Conventions are kept per repo: each product repo has its own `AGENTS.md`,
  CI and check, and branch rules are set per repo
  ([ADR-006](006-branch-protection.md)).
- Cross-repo work costs a commit and a push per repo, which the workspace
  makes cheaper but does not remove.
- Revisit if two products start sharing enough code that keeping them apart
  costs more than visibility and standalone reference value are worth.
