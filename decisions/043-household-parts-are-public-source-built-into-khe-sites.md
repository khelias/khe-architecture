# ADR-043: Household parts are public source, and khe-sites builds their room

- **Status:** Accepted (2026-11-19)
- **Related:** [ADR-012](012-estate-architecture-is-public.md) (the same split of public and private), [ADR-016](016-static-fallback-at-the-edge.md) (the room is static, so the edge copy serves it), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md) (the room's stage is a canvas with its own look)

## Context

We design 3D-printable parts for the household and print them on our own
printer. Their source has lived in download folders and session scratch
space, where a reboot can lose it. The parts are worth showing: each has a
reason to exist, a check that proves it fits and a real print behind it.

A part can carry family detail. One of the first two parts has a stamp with
a family name on it, and slicer projects hold the printer's profile. Once a
detail reaches a public repo it has to be treated as seen for good.

The room that shows the parts needs a home too. khe.ee already has a room
built from another repo's checkout, the 3D house at `/ha/`, built by
khe-sites from
[khe-home-assistant](https://github.com/khelias/khe-home-assistant). Stories
went the other way: khe-bunny-tales deploys its own builds, because its
sources are private.

## Decision

1. **The parts live in a public repo,
   [khe-workshop](https://github.com/khelias/khe-workshop).** It holds each
   part's source, its checks, the tools that build its page data and the
   room's code.
2. **Family data stays in the private working layer.** That is the family's
   stamp text, the slicer projects, the printer's profile and the exact files
   that were printed. A public part carries neutral defaults, and the family's
   values are parameters applied from outside the repo.
3. **The list of terms that must not appear publicly is private too.** The
   public check searches every file for those terms when the private list is
   beside the checkout, and a history search runs before a push. The list is
   never copied into a public repo.
4. **khe-sites builds the room from a checkout of khe-workshop,** as it builds
   `/ha/`. The room is plain ES modules with a vendored three.js and a
   standard-library Python builder, so the homelab runner installs nothing new.
5. **khe-workshop does not deploy anything itself.** It has no runner, no
   secrets and no container image.

## Alternatives considered

- **A private repo.** It would remove the risk of a family detail leaking, and
  also the reason for the room: visitors could not read, download or check the
  parts.
- **A deploy of its own, as khe-bunny-tales has.** That route exists for
  private sources. Public sources need no second deploy path.
- **The parts inside khe-sites.** Geometry, probes and print data have nothing
  to do with the site's own sources and would slow its checks.

## Consequences

- A part's public history cannot be taken back, so a part is added only after
  the terms search passes on the whole repo.
- Generated page data has to be committed, because G-code cannot be made in CI
  without the printer's profile. The repo's own decisions set its size budget.
- khe-sites gains a build input. Its checkout of khe-workshop is one more
  source that can break the site's build, as khe-home-assistant already is.
- A repo row on the architecture page appears before the room does. The room
  goes live only when its first part is published with proof.
