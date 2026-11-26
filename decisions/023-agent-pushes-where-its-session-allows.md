# ADR-023: The agent pushes and merges its own work where its session allows

- **Status:** Accepted (2026-11-26)
- **Supersedes:** [ADR-020](020-agent-work-through-pull-requests.md)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-008](008-container-images.md), [ADR-014](014-shared-ui-packages.md), [ADR-027](027-attended-and-unattended-agent-tiers.md)

## Context

- `khelias` is a personal GitHub account on the Free plan with one
  collaborator, its owner, as admin. Rulesets, required checks and
  auto-merge exist only for its public repos.
- Before this, the agent committed and a person pushed, because its session
  could not. That became one copy-pasted block per change, run unread: the
  look it was meant to give had stopped, and every change waited for it.
- The agent now also runs in a session that may push, use `gh` and reach
  the homelab VM over ssh, without the other session's guardrails.
- The agent runs in more than one harness: Claude Code, and on the laptop
  also Antigravity, whose hooks call the same gate through an adapter.
- The workspace commit gate loads in every session from the shared project
  settings and already runs each repo's check, the personal-data scan and
  the review requirement, so it is where an envelope for the agent's pushes
  can be enforced rather than only stated in prose.
- Branch rules do not cover the other route onto the home network: a fork
  PR to a public repo with a self-hosted runner can edit a workflow to
  target that runner.

## Decision

1. **Every public repo blocks deletion and non-fast-forward pushes on its
   default branch**, with no bypass. The settings are in
   [`ESTATE.md` "Adding a repo"](https://github.com/khelias/khe-architecture/blob/main/ESTATE.md#adding-a-repo).
2. **A repo whose push to `main` deploys also requires its CI check.**
   Admins are not bound by it, so an emergency push stays possible and
   GitHub reports it. A private repo (point 4) deploys only from a job that
   `needs:` its full check, as makett.khe.ee does (amended 2026-11-26).
3. **The agent pushes, opens pull requests and turns on auto-merge itself
   where its session allows it; where it does not, it hands the same
   commands to a person.** A public repo on the pull request route takes
   agent work to `main` through a pull request that merges only when its
   CI check and the personal-data scan pass, with no review, and with a
   merge commit so the shas the working notes cite survive. Other repos
   commit to `main` and push. The routes and what stays with a person (a
   push of another session's commits, a workflow change, a release that
   cannot be undone, secrets, destructive commands) are in the
   [workspace `AGENTS.md`](https://github.com/khelias/khe-workspace/blob/main/AGENTS.md);
   the gate's push refusals, the envelope this decision relies on, are in
   its [`AGENTS.md`](https://github.com/khelias/khe-workspace/blob/main/AGENTS.md#workspace-hooks).
   On the homelab VM the agent runs read-only diagnosis and the procedures
   in khe-homelab's
   [runbook](https://github.com/khelias/khe-homelab/blob/main/docs/runbook.md);
   host changes still go through git. The way back is a revert commit
   pushed the same way. On the laptop the agent may be Claude Code or
   Antigravity, each committing and pushing only through the workspace
   gate; a harness that cannot load the gate does not commit or push in
   the estate. On the homelab's agent VM it stays Claude Code (ADR-027).
4. **Private repos stay without branch rules.** What protects them is access
   (one collaborator) and backup. GitHub Pro is not bought for this.
5. **Every repo with a self-hosted runner requires approval of fork PR runs
   from all external contributors**, and a run is approved only after
   reading its workflow diff. Private repos need no such setting, because
   only collaborators can fork them.

Under ADR-007 the agent Acts where its session may push, else Proposes.

## Alternatives considered

- **Keep the person's push, or wait for a month of delivery data first.**
  The look before the push had already stopped being a look.
- **Rely on the session's permission rules alone.** Those live per machine
  and per instance; the gate is shared, versioned and runs in every session.
- **Required review, or checks that bind admins.** Protect against nobody
  with one collaborator, and block an emergency push.

## Consequences

- A change can reach `main` and deploy with no person in the loop, behind
  the gate and, on the pull request route, CI. A fix is a new commit.
- The CI scan runs after the branch is public, so it guards `main` and the
  deploy, not exposure; the local gate stays the guard against publishing
  personal data at all.
- A pull request can edit its own workflow to weaken the required job,
  which is why a workflow diff stays with a person.
- The gate matches the command line: a push inside a script or an alias is
  not seen; branch rules (point 1) still stop a force push. CI's rules lag
  the local ones until a repo moves its pin of the scan.
- A force push or a branch deletion needs a settings change first.
- The account is the single point of failure: whoever holds it can run code
  on the home network through any runner. It has two-factor authentication.
- Revisit if a second collaborator joins, if the repos move to an
  organisation, or if scheduled agents start to push unattended.
