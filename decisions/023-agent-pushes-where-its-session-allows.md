# ADR-023: The agent pushes and merges its own work where its session allows

- **Status:** Accepted (2026-11-12)
- **Supersedes:** [ADR-020](020-agent-work-through-pull-requests.md)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-008](008-container-images.md), [ADR-014](014-shared-ui-packages.md)

## Context

- `khelias` is a personal GitHub account on the Free plan with one
  collaborator, its owner, as admin. Rulesets, required checks and
  auto-merge exist only for its public repos.
- Under ADR-020 the AI coding agent committed locally and a person pushed,
  opened the pull request and turned on auto-merge, because the agent's
  session could not push. The person's part had become one copy-pasted
  block per change, run without reading it: the look it was meant to give
  had stopped happening, and every change waited for it.
- The agent now also runs in a session that may push, use `gh` and reach
  the homelab VM over ssh. There the guard that came for free (the agent
  could not push) is gone, and so is the other session's guardrail against
  force pushes and destructive commands.
- The workspace commit gate loads in every session from the shared project
  settings. It already runs each repo's check, the personal-data scan and
  the review requirement before a commit, so it is where an envelope for
  the agent's pushes can be enforced rather than only stated in prose.
- Branch rules do not cover the other route onto the home network: a public
  repo whose workflows run on a self-hosted runner can receive a fork PR
  that edits a workflow to target that runner.

## Decision

1. **Every public repo blocks deletion and non-fast-forward pushes on its
   default branch**, through a ruleset with no bypass actors, or classic
   branch protection where that is what the repo has.
2. **A repo whose push to `main` deploys also names its CI status check as
   required.** Admins are not bound by it, deliberately: a person's direct
   push stays possible for an emergency, and GitHub reports the bypassed
   rule.
3. **The agent pushes, opens pull requests and turns on auto-merge itself
   where its session allows it; where it does not, it hands the same
   commands to a person as before.** The routes are unchanged. In a public
   repo marked `pr: true` in the workspace's `repos/repos.yaml`, agent work
   reaches `main` through a pull request that merges only when its required
   checks pass: the repo's CI check and the personal-data scan, no review.
   It merges with a merge commit, because the branch's commits keep the
   shas the working notes and the delivery measures cite. The CI scan is a
   script in [khe-workspace](https://github.com/khelias/khe-workspace) run
   with the commit gate's rules, checked out at a pinned commit (ADR-008,
   ADR-014). Other repos keep the direct route: commit to `main`, push.
   Before its own push the agent fetches, confirms the branch is not behind
   and lists what the push ships.
   - **Kept with a person:** a push that would ship commits the session did
     not make; a diff under `.github/workflows/`; a release tag in
     `khe-ui`, which publishes to npm and cannot be undone; fetching
     secrets; destructive commands.
   - **The envelope is the commit gate plus the required checks.** Besides
     review, scan and check before a commit, the gate refuses any force
     push, a push to the default branch of a `pr: true` repo, a release tag
     push in `khe-ui` and `gh pr merge --admin`.
   - **On the homelab VM over ssh** the agent runs read-only diagnosis and
     the procedures written in `khe-homelab`'s
     [runbook](https://github.com/khelias/khe-homelab/blob/main/docs/runbook.md).
     Changes to the host still go through git; dispatching its deploy and
     retire workflows is the agent's.
   - **Fallback:** a revert commit pushed the same way; on the VM, the
     runbook.
4. **Private repos stay without branch rules.** What protects them is access
   (one collaborator) and backup. GitHub Pro is not bought for this.
5. **Fork PR approval for every repo with a registered self-hosted runner:**
   approval is required for all external contributors, and a fork run is
   approved only after reading its `.github/workflows/` diff. Private repos
   need no such setting, because only collaborators can fork them.

Under ADR-007 the agent moves from Proposes to Acts in a session that may
push; in one that may not, it still Proposes.

## Alternatives considered

- **Wait for a month of delivery data first.** The person's look before the
  push, which that data was to be compared against, had already stopped
  being a look; the after-the-fact measures (fixes and reverts, change
  failure rate) still apply.
- **Allow everything and rely on the session's permission rules alone.**
  Those rules live per machine and per instance; the gate is shared,
  versioned and runs in every session.
- **Keep ADR-020 as it was.** One round trip per change for a look that no
  longer happened.
- **Pull requests with required review, or checks that bind admins.** Still
  protect against nobody with one collaborator, and block an emergency push.

## Consequences

- A change can reach `main` and deploy with no person in the loop. What
  stands in front of it is the gate and, in a `pr: true` repo, CI on the
  branch. The agent can still break `main` with a commit that passes them;
  a fix is a new commit, never a rewrite.
- The CI scan runs after the branch is public, so it guards `main` and the
  deploy, not exposure. The local commit gate stays the guard against
  publishing personal data at all.
- A pull request can edit its own workflow to weaken the required job,
  which is why a workflow diff stays with a person.
- The gate does not stop a `git merge`, `cherry-pick` or `revert` onto the
  local `main`; pushing that `main` directly is the admin bypass of point 2,
  which GitHub reports. The rules in CI lag the local ones until a repo
  moves its pin.
- The gate's push rules match the command line; a push hidden inside a
  script or an alias is not seen. Branch rules (point 1) still stop a force
  push to a public default branch.
- A force push or a branch deletion needs a deliberate change to the repo's
  settings first. A new public repo gets the ruleset when it is created,
  and the fork PR approval setting if it gets a self-hosted runner.
- The account is the single point of failure: whoever holds it, or a
  session signed in to it, can run code on the home network through any
  runner. It is protected with two-factor authentication.
- Revisit if a second collaborator joins, if the repos move to an
  organisation, or if scheduled agents start to push unattended.
