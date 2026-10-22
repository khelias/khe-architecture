# ADR-020: Agent work reaches main through a pull request whose checks pass

- **Status:** Accepted (2026-10-22)
- **Supersedes:** [ADR-006](006-branch-protection.md)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-008](008-container-images.md), [ADR-014](014-shared-ui-packages.md)

## Context

- `khelias` is a personal GitHub account on the Free plan, not an
  organisation. Its owner is the only collaborator on every repo, as admin.
  Nobody else can merge, and that follows from access control, not from
  branch rules.
- Commits are made by an AI coding agent, which commits locally while a
  person pushes; the agent's session cannot push. The realistic threat is
  that agent: a session that rewrites `main` history or ships broken code.
  On the deploy repos a push to `main` is a deploy, some of it run by a
  self-hosted runner on the homelab VM.
- ADR-006 kept pull requests out of that loop. The checks that ran before
  `main` moved were the local ones in the agent's session: each repo's own
  check and a personal-data scan, run before every commit. CI ran after the
  push, beside the deploy, so a change that CI rejected had already
  deployed. A commit made with the local checks skipped, or from somewhere
  without them, reached `main` with nothing checking it first.
- A pull request lets the required checks run before `main` moves without
  anyone reviewing it: auto-merge merges it once they pass. A review
  requirement still protects against nobody when there is one
  collaborator.
- On GitHub Free, rulesets, required checks and auto-merge exist only for
  public repos.
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
3. **In a public repo marked `pr: true` in the workspace's
   `repos/repos.yaml`, agent work reaches `main` through a pull request
   that merges only when its required checks pass:** the repo's CI check
   and the personal-data scan. No review is required. The agent commits on
   a branch; a person pushes it, opens the pull request and turns on
   auto-merge. It merges with a merge commit, because the branch's commits
   keep the shas that the working notes and the delivery measures cite;
   squash and rebase would rewrite them. The CI scan is a script in
   [khe-workspace](https://github.com/khelias/khe-workspace) run with the
   same rules as the local commit gate, and each repo checks khe-workspace
   out at a pinned commit, as the estate pins images and packages
   (ADR-008, ADR-014): khe-workspace owns the scan and its rules, and there
   is one copy of them. A repo joins with its own `pr: true` line once its
   CI runs on pull requests; until then it keeps the direct route, where the
   agent commits to `main` locally and a person pushes.
4. **Private repos stay without branch rules.** What protects them is access
   (one collaborator) and backup. GitHub Pro is not bought for this.
5. **Fork PR approval for every repo with a registered self-hosted runner:**
   approval is required for all external contributors, and a fork run is
   approved only after reading its `.github/workflows/` diff. Private repos
   need no such setting, because only collaborators can fork them.

## Alternatives considered

- **Pull requests with required review.** Protects against nobody when there
  is one collaborator, and costs a round trip on every change.
- **Required checks that bind admins.** Would block a person's emergency
  push, and adds nothing the pull request route does not already give.
- **CI after the push, as ADR-006 had it.** The deploy runs before CI has
  said anything.
- **A copy of the scan rules in each repo.** The copies drift apart; a pin
  keeps one source and makes each update a visible commit.
- **Squash or rebase merges.** They rewrite the shas the working notes cite.
- **GitHub Pro for rules on private repos.** Not worth it for one
  collaborator; access and backup already cover the risk.

## Consequences

- In a `pr: true` repo, `main` and its deploy move only after the CI check
  and the personal-data scan pass on the branch. The workspace commit gate
  refuses an agent commit on the default branch there, with a named skip
  for an emergency.
- The CI scan runs after the branch is public, so it guards `main` and the
  deploy, not exposure. The local commit gate stays the guard against
  publishing personal data at all.
- A pull request can edit its own workflow to weaken the required job. A
  diff under `.github/workflows/` gets a person's look before it is pushed,
  as a fork run's does under point 5.
- The gate does not stop a `git merge`, `cherry-pick` or `revert` onto the
  local `main`; pushing that `main` directly is the admin bypass of point 2,
  which GitHub reports.
- The rules in CI lag the local ones until a repo moves its pin.
- Every change waits for a branch, a pull request and CI before it deploys;
  the person's part is one block of commands.
- The agent can still break `main` with a commit that passes the checks. A
  fix is a new commit, never a rewrite.
- A force push or a branch deletion needs a deliberate change to the
  repo's settings first, so it cannot happen by accident. The procedure
  lives in `khe-homelab`'s
  [runbook](https://github.com/khelias/khe-homelab/blob/main/docs/runbook.md).
- A new public repo gets the ruleset when it is created, and the fork PR
  approval setting if it gets a self-hosted runner. Joining the pull
  request route takes CI on pull requests, the scan job, both checks
  required, auto-merge allowed and the `pr: true` line.
- The account is the single point of failure: whoever holds it can run code
  on the home network through any runner. It is protected with two-factor
  authentication.
- Revisit if a second collaborator joins, if the repos move to an
  organisation, or if GitHub Pro is taken for another reason.
