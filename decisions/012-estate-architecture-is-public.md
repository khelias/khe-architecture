# ADR-012: Estate decisions and index are public in khe-architecture; khe-meta stays private

- **Status:** Accepted (2026-10-07)
- **Supersedes:** [ADR-005](005-khe-meta-is-private.md)
- **Related:** [ADR-001](001-repo-per-product.md)

## Context

[ADR-005](005-khe-meta-is-private.md) kept `khe-meta`, the estate's
cross-repo layer, private because it holds the house documentation and the
working plans. Its decisions were the exception in content: written for
publication and meant to be published in full. In practice that left them
in a repo nothing public can read.

The decisions are to be published on `khe.ee/architecture`, built by the
public `khe-sites`. Its CI runs on GitHub-hosted runners and its deploy on
a homelab runner; neither can read a private repo without a credential. A
credential that reads `khe-meta` reads the house documentation too, from
the deploy job of a public repo. A copy of the decisions inside
`khe-sites` would be a second text of every decision to keep in step.

The estate index is in the same position. It describes public repos and
public hostnames, and it is the first thing an agent working across the
estate reads.

## Decision

A public repo, `khe-architecture`, holds the estate's architecture: the
decisions in `decisions/` and the estate index `ESTATE.md`. Whatever
publishes or cites them reads them from there; nothing is copied.

`khe-meta` stays private, for the reason ADR-005 gave, restated here
because this ADR replaces it: it holds the house documentation, the working
plans and the estate roadmap. What would make it public is unchanged: the
house documentation and the plans leave it.

The decisions start a fresh history in `khe-architecture`. They are copied
in, not filtered out of the `khe-meta` history, whose earlier versions were
not written for publication.

Other repos cite a decision as "estate ADR-NNN", with a GitHub link in
Markdown docs, so a citation does not name the repo that holds it.

## Alternatives considered

- **A copy in `khe-sites`.** Two texts of every decision, one of them
  drifting.
- **A read credential for `khe-meta` in `khe-sites`.** The house
  documentation readable from the deploy job of a public repo.
- **The [`khe`](https://github.com/khelias/khe) workspace repo.** Already
  public, but its role is agent tooling; the estate's architecture would
  blur it.
- **`khe-sites` itself.** A site repo would own the estate's decisions,
  where its role is to publish them.
- **Making `khe-meta` public.** Its history holds the house documentation
  and the plans; they would have to leave the history, not only the tree.

## Consequences

- The cross-repo layer is split by visibility, the split ADR-005 named as
  its alternative: the public architecture in `khe-architecture`, the
  private working layer in `khe-meta`. Whether a document can be published
  decides which repo it goes in. Where
  [ADR-001](001-repo-per-product.md) places cross-repo concerns in
  `khe-meta`, that now means both repos.
- The decisions are in a public repo, so the personal-data scan that runs
  before each commit in public repos covers them; as part of a private repo
  they were outside it.
- A new or changed decision reaches `khe.ee/architecture` on the next
  `khe-sites` deploy, with no credential and no copy in between.
- `khe-architecture` gets the default-branch rules of
  [ADR-006](006-branch-protection.md), like every public repo.
- What ADR-005 required of `khe-meta` still holds: private is not a place
  to stash secrets, identifiers stay out of everything but the house
  documentation, and public repos that link there accept that readers
  without access get a 404.
