# ADR-008: Container images are built in CI, published to GHCR and pinned in khe-homelab

- **Status:** Accepted (2026-09-28)
- **Related:** [ADR-009](009-backend-language-per-app.md), [ADR-010](010-one-host-docker-compose.md)

## Context

- The estate's first container image, the adventure game's AI proxy, was
  built on the homelab VM by a self-hosted runner and tagged `latest`: no
  registry, no version, no rollback, no SBOM and no scan. The game's
  frontend was built on the same VM, with configuration baked into the bundle.
  Both existed only on that VM, so a rebuild on an empty VM could not
  start the game.
- Two app backends are coming, in two languages
  ([ADR-009](009-backend-language-per-app.md)). They should arrive on one
  platform, not two.
- Every estate repo that ships a container is affected (`khe-ai-adventure`
  first, then the `khe-trips` and `khe-study` backends), and so is
  `khe-homelab`, which runs them on Compose
  ([ADR-010](010-one-host-docker-compose.md)).

## Decision

### Build, registry, tags and pins

1. **Images are built on GitHub-hosted runners**, never on the VM. The image
   that runs is rebuilt from the same commit, lockfiles and digest-pinned
   base images as the one that was scanned, not copied from it (point 5).
2. **Registry: GHCR, as `ghcr.io/khelias/<repo>-<part>`.** Packages are
   public, so neither the VM nor a fresh recovery VM needs registry
   credentials.
3. **Tags: `main` (moves) and `sha-<full commit>` (never moves).** Publish
   never overwrites a `sha-` tag and stops unless its commit is still the
   tip of `main`, so a re-run of an old commit cannot move `main` backwards.
4. **Pins live in `khe-homelab` as `image: <name>:main@sha256:<digest>`.**
   Homelab git says what runs, a rollback is a git change, and a rebuild
   knows what to pull.

### Build and publish jobs

5. **Two jobs.** `images` builds and scans every image on every PR and push,
   with read-only permissions, and is the required check. `publish` runs
   only on a push to `main` after the quality and `images` jobs, and is the
   only job that can write packages, mint an OIDC token or write
   attestations. It rebuilds, pushes with an SBOM and maximal provenance,
   attests every new `sha-` digest and checks the attestations before it
   moves `main`. The scanner never runs in a job that can write packages.
   **No cache in publish:** the GitHub Actions cache is writable by any step
   that holds the runner's cache token, which includes a container action
   such as the scanner and an install script in the quality job. A poisoned
   cache can then at most mislead a later scan, never what is published.
6. **Scan gate: Grype**, run as a container pinned by digest, failing on HIGH
   or CRITICAL findings that have a fix. Trivy was the default candidate and
   was not taken: its release channels were compromised twice in March 2026
   (GHSA-69fq-xp46-6x23: a malicious release and hijacked action tags, then
   malicious Docker Hub images after a credential rotation that had not
   locked the attacker out). A digest pin would have avoided both, but a
   scanner is exactly where a supply-chain compromise pays off. The scanner
   has its own Renovate rule: no automerge, a minimum release age of 7 days.
7. **The only way past a finding that cannot be fixed yet is the ignore
   file.** Each rule's reason starts with `until YYYY-MM-DD:`, and the
   `images` job fails once a date has passed, because Grype has no expiry
   field of its own.
8. **Runtime stages carry no package manager,** so the gate does not trip on
   tooling the app never runs; a web image holds only its built assets and a
   non-root web server.

### Moving pins and rolling back

9. **The app's CI writes the pin.** After `publish` has moved the `main`
   tags, a pin job pushes the new digests to a `deploy/<repo>` branch in
   `khe-homelab`, opens the PR and turns on auto-merge. It skips unless
   GHCR's `main` still points at its own commit, so an old run cannot pin
   backwards. Renovate is disabled for the estate's images.
10. **The cross-repo credential is a GitHub App per source repo,** installed
    on `khe-homelab` only, with Contents and Pull requests write and nothing
    else. One App per repo means a compromised repo cannot re-pin another
    app. Its key lives in an environment of the app repo limited to `main`,
    so a branch or PR run cannot read it.
11. **Two checks in homelab's required validation make an App PR safe to
    automerge,** both run from the base branch against the PR tree so a PR
    cannot weaken them: a guard that lets the App change nothing but its own
    image digests, one line for one line; and an attestation check that every
    pinned estate digest was built by its own repo's CI on `main` on a
    GitHub-hosted runner.
12. **Accepted residual risk.** The App can merge, or fast-forward `main` to,
    a commit that is already green but written by someone else, so a
    held-back update could go live early; neither path ships content that
    has not passed validation. Requiring a pull request on `khe-homelab`'s
    `main` would close both, and is the fix if this ever matters.
13. **Rollback pins every image of the app to the same
    `sha-<commit>@sha256:<digest>`.** The pin job leaves a `sha-` pin alone,
    so the rollback holds across later pushes until the pins return to
    `:main@sha256:<current>`.

### Atomicity of an app's images

An app whose images depend on each other (the adventure frontend and proxy
share an exact schema-hash allowlist) ships them as one unit: all built from
the same commit in one run, every `sha-` tag pushed before any `main` tag
moves, all pins moved in one commit from the `sha-` tags, and the
attestation check refuses a PR whose images of one repo come from different
commits.

### Runtime config and backend convention

14. **An image is the same in every environment.** Configuration, secrets
    included, comes from the container's environment at start; a static
    frontend gets a `config.js` written at start. A value that must reach a
    browser is still readable by every visitor, but it is not stored in a
    public image, and rotating it needs no rebuild.
15. **One workflow file per repo for now,** extracted into a public reusable
    workflow when the second caller arrives.

Every app backend runs as a non-root user, has a healthcheck, logs JSON to
stdout, has a memory limit in Compose, and runs migrations as a one-shot
Compose service that the app waits on.

## Alternatives considered

- **Renovate moves the pins**, with no cross-repo credential. Its registry
  lookups lag the registry by hours, where the App takes minutes, and a
  lagging lookup could propose an older digest after CI moved the pin and
  automerge a silent downgrade.
- **Trivy as the scanner:** see point 6.

## Consequences

- A fresh VM pulls every estate image anonymously from GHCR at the digest
  homelab git names.
- The pin App deploys to production with no person in the loop, inside the
  envelope of points 5, 6 and 11. It is the kind of automated writer
  [ADR-007](007-automated-writers.md) proposes a rule for.
- **Private repos (`khe-trips`)** pay twice: pulling their images needs a
  read token on the VM, and artifact attestations are not available for
  private repos on GitHub Free, which point 11 needs. How `khe-trips` pins
  are checked has to be decided before it gets images.
- An app repo on images no longer needs a self-hosted runner, which shrinks
  the fork-PR surface of [ADR-006](006-branch-protection.md).
- Not decided here: Kubernetes ([ADR-010](010-one-host-docker-compose.md)),
  multi-arch images (the VM is amd64), and an image retention policy
  (revisit when GHCR storage shows up).
