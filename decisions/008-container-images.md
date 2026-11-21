# ADR-008: Container images are built in CI, published to GHCR and pinned in khe-homelab

- **Status:** Accepted (2026-11-21)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-007](007-automated-writers.md), [ADR-010](010-one-host-docker-compose.md), [ADR-023](023-agent-pushes-where-its-session-allows.md)

## Context

The estate's first images, the adventure game's AI proxy and frontend,
were built on the homelab VM and tagged `latest`: no registry, version,
rollback, SBOM or scan, and the frontend's configuration was baked in. A
rebuild on an empty VM could not start the game. More app backends were
coming, in more than one language ([ADR-004](004-app-backend-and-identity.md)),
to run on Compose in `khe-homelab` ([ADR-010](010-one-host-docker-compose.md)).

## Decision

The job layout, tags, scan and ignore formats and the backend conventions
are in khe-homelab's
[operational notes](https://github.com/khelias/khe-homelab/blob/main/docs/operational-notes.md#image-pins).

1. **Images are built on GitHub-hosted runners**, never on the VM. The image
   that runs is rebuilt from the same commit, lockfiles and pinned base
   images as the one that was scanned, not copied from it.
2. **Registry: GHCR, with public packages,** so neither the VM nor a fresh
   recovery VM needs registry credentials.
3. **A moving `main` tag and a per-commit tag that never moves.** Publish
   never overwrites a commit tag and never moves `main` backwards.
4. **Pins live in `khe-homelab` by digest.** Homelab git says what runs, a
   rollback is a git change, and a rebuild knows what to pull.
5. **Scanning and publishing are separate jobs.** The job that builds and
   scans every change can only read and is the required check. Only the
   publish job, after the checks on `main`, can write packages, mint a token
   or write attestations, and it uses no cache, which any step of a reading
   job can write. The scanner never runs in a job that can write.
6. **The scan gate is Grype**, pinned by digest, failing on high or critical
   findings that have a fix. Trivy, the default candidate, had its release
   channels compromised twice in March 2026 (GHSA-69fq-xp46-6x23), and a
   scanner is where a supply-chain compromise pays off. Scanner updates are
   never automerged and wait a week.
7. **The only way past a finding that cannot be fixed yet is a dated ignore
   rule,** which fails the scan once its date has passed.
8. **Runtime stages carry no package manager,** so the gate does not trip
   on tooling the app never runs.
9. **The app's CI writes the pin** through an auto-merging pull request in
   `khe-homelab`, only while the registry's `main` still points at its own
   commit, so an old run cannot pin backwards. Renovate does not move them.
10. **The cross-repo credential is a GitHub App per source repo,** installed
    on `khe-homelab` only, with write access to contents and pull requests
    and nothing else, its key usable only from `main`. One App per repo
    means a compromised repo cannot re-pin another app.
11. **Two checks in homelab's required validation make an App PR safe to
    automerge,** both run from the base branch so a PR cannot weaken them:
    the App may change nothing but its own image digests, and every pinned
    estate digest must be attested as built by its own repo's CI on `main`
    on a GitHub-hosted runner.
12. **Accepted residual risk.** The App can merge, or fast-forward `main`
    to, a green commit someone else wrote, so a held-back update could go
    live early, though nothing unvalidated; a required pull request on
    `khe-homelab`'s `main` would close it.
13. **Rollback pins every image of the app to the same commit tag and
    digest,** which the pin job leaves alone until the pins return to `main`.
14. **An image is the same in every environment.** Configuration, secrets
    included, comes from the container's environment at start, so no secret
    is stored in a public image and rotating one needs no rebuild.
15. **One workflow file per repo for now,** extracted into a public reusable
    workflow when the second caller arrives.
16. **An app whose images depend on each other ships them as one unit:**
    built from one commit, published before any `main` tag moves, pinned in
    one commit, and refused by the attestation check if they are not.

## Alternatives considered

- **Renovate moves the pins**, with no cross-repo credential. Its registry
  lookups lag the registry by hours, where the App takes minutes, and a
  lagging lookup could propose an older digest after CI moved the pin and
  automerge a silent downgrade.

## Consequences

- A fresh VM pulls every estate image anonymously at its pinned digest.
- The pin App deploys to production with no person in the loop, inside the
  envelope of points 5, 6 and 11: an automated writer under
  [ADR-007](007-automated-writers.md).
- A private repo pays twice: its images need a read token on the VM, and
  GitHub Free has no attestations for private repos, which point 11 needs.
- An app repo on images needs no self-hosted runner, which shrinks the
  fork-PR surface of [ADR-023](023-agent-pushes-where-its-session-allows.md).
- Not decided here: Kubernetes (ADR-010), multi-arch images and an image
  retention policy.
