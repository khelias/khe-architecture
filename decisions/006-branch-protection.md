# ADR-006: Branch protection is autonomy with minimal guards

- **Status:** Accepted (2026-06-06)

## Context

- `khelias` is a personal GitHub account on the Free plan, not an
  organisation. Its owner is the only collaborator on every repo, as admin.
  Nobody else can merge, and that follows from access control, not from
  branch rules.
- Commits are made by an AI coding agent, which commits locally while a
  person pushes. The realistic threat is that agent: a session that rewrites
  `main` history or ships broken code. On the deploy repos a push to `main`
  is a deploy, some of it run by a self-hosted runner on the homelab VM.
- The working loop depends on the agent committing to `main` and CI
  deploying without a pull request round trip. A PR or review requirement
  would add a click to every change and would protect against nobody.
- On GitHub Free, rulesets and branch protection exist only for public
  repos.
- Branch rules do not cover the other route onto the home network: a public
  repo whose workflows run on a self-hosted runner can receive a fork PR
  that edits a workflow to target that runner.

## Decision

1. **Every public repo blocks deletion and non-fast-forward pushes on its
   default branch**, through a ruleset with no bypass actors, or classic
   branch protection where that is what the repo has.
2. **A repo whose push to `main` deploys also names its CI status check as
   required.** Admins are not bound by it, deliberately: a check that bound
   admins would reject every direct push, because a fresh commit has no CI
   result yet. A direct
   push goes through and GitHub reports the bypassed rule.
3. **No PR requirement and no review requirement anywhere.** The agent
   commits to `main` locally, and a person pushes.
4. **Private repos stay without branch rules.** What protects them is access
   (one collaborator) and backup. GitHub Pro is not bought for this.
5. **Fork PR approval for every repo with a registered self-hosted runner:**
   approval is required for all external contributors, and a fork run is
   approved only after reading its `.github/workflows/` diff. Private repos
   need no such setting, because only collaborators can fork them.

## Alternatives considered

- **Pull requests with required review.** Protects against nobody when there
  is one collaborator, and costs a round trip on every change.
- **Required checks that bind admins.** Would block every direct push to
  `main`, which is the working loop.
- **GitHub Pro for rules on private repos.** Not worth it for one
  collaborator; access and backup already cover the risk.

## Consequences

- The agent can still break `main` with a bad commit. Because the required
  check does not bind admin pushes, the check that actually runs before
  `main` moves is the local one: each repo's own check and a personal-data
  and secret scan, run before every commit. CI runs after the push, next to
  the deploy. A fix is a new commit, never a rewrite.
- A force push or a branch deletion needs a deliberate change to the
  repo's settings first, so it cannot happen by accident. The procedure
  lives in `khe-homelab`'s
  [runbook](https://github.com/khelias/khe-homelab/blob/main/docs/runbook.md).
- A new public repo gets the ruleset when it is created, and the fork PR
  approval setting if it gets a self-hosted runner.
- The account is the single point of failure: whoever holds it can run code
  on the home network through any runner. It is protected with two-factor
  authentication.
- Revisit if a second collaborator joins, if the repos move to an
  organisation, or if GitHub Pro is taken for another reason.
