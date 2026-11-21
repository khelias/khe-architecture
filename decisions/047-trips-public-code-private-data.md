# ADR-047: Trips: public app code, private trips, deployed by the data repo

- **Status:** Accepted (2026-11-21)
- **Related:** [ADR-001](001-repo-per-product.md) (deviates, as ADR-031 does: a public app deployed by its private data repo), [ADR-004](004-app-backend-and-identity.md) (point 5: the agent's edits arrive as proposals), [ADR-007](007-automated-writers.md), [ADR-008](008-container-images.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)

## Context

`khe-trips` is private because the family's trips are in it: every trip,
the photos, the household's planning criteria, and a history in which each
of these has been committed many times. The code itself holds nothing
private once the trips are out of it, and it is meant to be a reference
project and, later, a template others can fork.

Three changes make the split due now. The backend, TypeScript on Node in
khe-trips' own decisions, ships as a container image, and
[ADR-008](008-container-images.md)'s attestation check needs a public repo,
since a private one on GitHub Free has none. Invited friends will reach the
app, so trip data leaves the client bundle anyway. And the agent that
authors most trips runs where it cannot reach the trips API behind
Cloudflare Access; it needs a route that does not hand it a credential to
the family's data.

The stories app solved the same shape in
[ADR-031](031-stories-public-app-private-stories-audio-outside-git.md):
public code, private content, the content repo owning the deploy.

## Decision

1. **Two homes.** The code lives in a new public `khe-trips` whose history
   starts clean: no commit in it has ever held family data. It carries
   invented demo trips as fixtures and runs CI on GitHub-hosted runners.
   The family's trips, their photos, the planning criteria, the app's
   secrets and the deploy live in a private `khe-trips-data`. The old
   repo's history is archived privately, not deleted.
2. **Files enter the public repo by allowlist.** No upcoming trip's name or
   dates appear in it, in its docs or in an estate ADR, since a public date
   says when the house is empty.
3. **The data repo owns the deploy.** It checks out the code at a pinned
   commit, builds the static sites (the atlas while it is static, the share
   sites and the demo) from its own data, and deploys them. This deviates
   from ADR-001 as ADR-031 does: the family's data never enters the public
   repo or its CI.
4. **The pinned commit and the image come from the same code.** The backend
   image is built by the public repo's CI and pinned by digest in
   khe-homelab (ADR-008). The data repo's deploy refuses to run when its
   pinned commit is not the commit that image was built from.
5. **The agent writes trips through a branch and a proposal.** The agent
   edits an exported trip document on a branch of the data repo. A
   model-free job on the homelab posts the change as a proposal against the
   revision it was exported from, under a service identity of its own, and
   a person accepts it in the app after reading its diff. That is
   [ADR-004](004-app-backend-and-identity.md) point 5: automated sources
   write proposals, never trips.
6. **The database exports back to the data repo.** The share sites and the
   demo are built from that export with the leak checks they run today.
   Publishing is an owner's action, so a friend's edit never goes public by
   itself, and an export that holds fewer shared trips than the last good
   one is refused rather than emptying the share sites.

For the public demo, a decision of khe-trips' own, this means the data repo
builds it from the export with the public code. The atlas stays behind
Access, and planning data and upcoming trips never leave the data repo and
the database.

## Alternatives considered

- **Keep one private repo.** No attestations for the image, no reference
  project, and the template would still need the data taken out first.
- **Publish the old repo after rewriting its history.** A filter that
  misses one file or one commit publishes it for good, and the history
  holds every trip in many versions.
- **One public repo with the data encrypted in it.** One wrong commit puts
  the plain text in a public history, and the keys become a secret every
  machine has to hold.
- **The agent calls the API directly.** It would need a credential to the
  family's trips on a machine whose network is held to a short allowlist,
  and its edits would skip the proposal a person reads.

## Consequences

- The code can be read and cloned on its own, with demo trips in place of
  the family's.
- A deploy needs both repos, and moving the pinned code commit in the data
  repo is a deliberate commit.
- The agent's trip edits become proposals: slower than a commit and a
  deploy, but read by a person before they reach the trip.
- The export job and the proposal job are automated writers and join the
  register of [ADR-007](007-automated-writers.md) in the change that adds
  them.
