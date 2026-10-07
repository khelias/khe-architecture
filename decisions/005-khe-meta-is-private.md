# ADR-005: khe-meta is private

- **Status:** Superseded (2026-05-03)
- **Superseded by:** [ADR-012](012-estate-architecture-is-public.md)

## Context

`khe-meta` is the estate's cross-repo layer: the estate index, the
cross-repo roadmap, these decisions, the working plans for every repo
(private ones included), and the house documentation that is too
identifying for the public `khe-homelab`. Most estate repos are public,
and the public repos are meant as reference projects
([ADR-001](001-repo-per-product.md)), so a private one needs a reason. The
question also decides what other repos may link to or copy from it.

When the repo was made private, the reason was its roadmap: it had become a
prioritised list of the estate's open weaknesses, each discoverable from the
public repos, but different in kind when collected in one document. That
list has since been closed; the house documentation and the plans keep
the repo private on their own.

## Decision

`khe-meta` stays private, because it holds the house documentation and the
working plans.

Its `decisions/` directory is the exception in content, not in visibility:
it is written for publication and published in full.

**What would make it public again:** the house documentation and the plans
leave the repo. Both have to move before visibility is reconsidered.

## Alternatives considered

- **Public, with the sensitive parts elsewhere:** possible once the house
  documentation and plans have another home; until then it would mean
  splitting the cross-repo layer across repos.

## Consequences

- Private is not a place to stash secrets: credentials stay out of the repo
  everywhere, and identifiers stay out of everything but the house
  documentation.
- The decisions are written to a publication standard: nothing identifying,
  no list of open weaknesses, no internal provenance. They can be published
  as they are, for example on `khe.ee/architecture`.
- Public repos can link here, and readers without access get a 404. Anything
  a public repo needs to stand on its own is written in that repo.
- GitHub Free gives a private repo no branch rules
  ([ADR-006](006-branch-protection.md)); access and backup protect it.
