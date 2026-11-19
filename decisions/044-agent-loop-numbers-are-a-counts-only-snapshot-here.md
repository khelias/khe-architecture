# ADR-044: The agent loop's numbers are published from a counts-only snapshot in khe-architecture

- **Status:** Accepted (2026-11-19)
- **Related:** [ADR-012](012-estate-architecture-is-public.md) (what this repo holds), [ADR-007](007-automated-writers.md) (the writer), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md) (the page that shows them)

## Context

The page about how the estate is built with agents, `khe.ee/agents/`, says
what the agent loop does but shows no number that proves it. The numbers
exist: each finished task records what its plan review, plan check, code
review and security review found, what was acted on and what was dropped,
and how its push went. A workspace script sums them from the task plans,
the git history of the repos and GitHub's CI runs.

The plans are private, in khe-meta, and the script needs every repo and
GitHub's API. The page is built by the public
[khe-sites](https://github.com/khelias/khe-sites), whose CI runs on
GitHub-hosted runners and whose deploy runs on a homelab runner. Neither can
read khe-meta without a credential that also reads the house documentation
(the reason ADR-012 gave). A number shown on the site has to be a snapshot
built with the site, not fetched by the visitor.

Each task already ends with a retro, run by the attended workspace agent,
which has every repo checked out and GitHub access.

## Decision

1. **The numbers live in khe-architecture, as `metrics/agent-loop.json`.**
   khe-sites reads the file at build through the same checkout of this repo
   it reads the decisions from, and a deploy publishes the current file.
2. **The file holds counts only.** It has exactly these keys: `since` and
   `until` (dates); `plans`; `planReview`, `planCheck`, `codeReview` and
   `securityReview`, each with `acted`, `dropped`, `notRun` and `pending`;
   one key for the owner's own review, with `acted`, `notRun` and
   `pending`; `push` with
   `unchanged`, `changed`, `discarded` and `pending`; `pushedPlans` and
   `revertedPlans`; and `planToPush` with `count` and `medianMinutes`. Every
   value but the two dates is a whole number. No plan name, commit, commit
   subject or path goes in it.
3. **The retro writes it.** After a task's last commit, the workspace agent
   runs the script with `--json` into this repo's main checkout. When a count
   changed it runs this repo's check and pushes one commit with the fixed
   message "agent-loop numbers". The writer is the attended agent already in
   the writer register; it gains this push, and no new writer is added.
4. **The commit carries the review skip.** The workspace commit gate counts
   a JSON file as code and asks for a review; there is nothing to review in
   generated counts, so the commit names the skip, and the retro reports it.
5. **A bad file is caught twice.** khe-sites fails its build and deploy on a
   missing key, an unknown key or a count that is not a whole number, so the
   live page keeps its last good numbers. To keep that from blocking an
   unrelated deploy, this repo's check holds the file to the same key set in
   CI, and the retro runs it before the push.

## Alternatives considered

- **A weekly GitHub job.** It would need two new GitHub Apps to read the
  private plans and the other repos, a workflow change and a guard in
  khe-sites CI. The retro already has all of that.
- **The snapshot in khe-sites, through a pull request per retro.** That is a
  dozen pull requests a week for a file of counts.
- **khe-sites reading khe-meta at build.** A private-read credential in a
  public repo's deploy, which ADR-012 ruled out.

## Consequences

- The diff between two snapshots shows one task's counts. That is accepted:
  counts of findings are not private, and the task's name is in neither the
  file nor the commit.
- The page's numbers lag the latest task until the next khe-sites deploy,
  on a merge there or its weekly run.
- This repo, until now decisions and the index only, gains a generated file.
  Its check grows by the key set and nothing else.
- In a session that cannot push, the retro skips the refresh and says so; the
  numbers wait for the next retro that can.
