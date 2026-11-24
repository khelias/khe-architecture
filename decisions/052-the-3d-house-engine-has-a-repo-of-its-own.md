# ADR-052: The 3D house engine has a repo of its own, and its consumers vendor a pinned copy

- **Status:** Accepted (2026-11-24)
- **Related:** [ADR-001](001-repo-per-product.md) (one repo per product), [ADR-012](012-estate-architecture-is-public.md) (the same split of public and private), [ADR-014](014-shared-ui-packages.md) (shared packages are presentation), [ADR-043](043-household-parts-are-public-source-built-into-khe-sites.md) (a public part with neutral defaults, a consumer's checkout)

## Context

The 3D view of the house grew up inside khe-home-assistant: the engine, its
model format and validator, the standalone viewer build and a made-up test
house, beside the Home Assistant card that shows our house with its devices.
khe-home-assistant's ADR-001 point 5 kept it there: the only other reader
was a private side project reading it by path.

Drawing two other houses from their drawings showed that the engine also
carried our house's look, its colours, boards and trims. That look is now
model data with a neutral default, which made the engine a part of its own
that any house can use. Every engine change still meant a commit in the
repo that deploys our house's configuration, and its tests and baselines
ran on every change to the dashboard.

## Decision

1. **The engine has a public repo of its own,
   [khe-house3d](https://github.com/khelias/khe-house3d).** It holds the
   engine, the model format and its validator, the viewer build with its
   privacy scan, the placement and surroundings tools, and the engine's
   tests. This supersedes khe-home-assistant ADR-001 point 5.
2. **The made-up test houses live with it.** The engine's tests and
   baselines run on them. The main test house also carries the devices the
   khe.ee/ha demo is built on, so a demo that needs a new test device takes
   an engine commit and a new copy.
3. **A consumer carries a vendored copy pinned to a commit,** at the same
   paths as in khe-house3d, written by khe-house3d's copy script, which
   travels in the copy, and checked against a committed list of file hashes
   on every check, so a hand edit of the copy cannot be committed (amended
   2026-11-24). khe-home-assistant does this for its card and its demo, so
   the served paths, the deploy and khe-sites' demo build stay as they were,
   and one revert there undoes an engine bump. khe-makett, a private side
   project that deploys nothing, is the second consumer.
4. **khe-house3d deploys nothing.** It has no runner, no secrets and no
   image; its CI runs its check on a GitHub-hosted runner.
5. **It holds only made-up houses.** A real house's model, devices and look
   stay in private documentation, and the repo's check scans for our
   house's data whenever the private model is at hand, as khe-home-assistant
   does.

## Alternatives considered

- **Stay in khe-home-assistant and read it by path.** What ADR-001 point 5
  chose. It ties every engine change to the repo that deploys the house and
  leaves a reusable part inside one house's configuration.
- **An npm package.** ADR-014 keeps shared packages to presentation, the
  consumer has no npm project, and HA serves plain files from its local
  folder, so they would be copied out of the package anyway.
- **A checkout at deploy time,** as ADR-043 has khe-sites build the
  workshop. The deployed engine would depend on a second checkout, the
  deploy would change, and a revert in the consumer would no longer undo an
  engine change.
- **A git submodule.** The workspace's sync, commit gate and worktrees do
  not handle them.

## Consequences

- An engine change lands in two steps: a commit in khe-house3d, then a bump
  of the copy in each consumer with the card's version. A copy can lag; the
  hash list says which commit it is.
- The engine's tests run in khe-house3d only; a consumer runs its own tests
  over the copy.
- The engine's history before the move stays in khe-home-assistant.
