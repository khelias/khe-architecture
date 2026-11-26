# khe-architecture

Workspace-wide rules (push, review, docs, estate ADRs) are in [khe-workspace
`AGENTS.md`](https://github.com/khelias/khe-workspace/blob/main/AGENTS.md).

The public architecture of the KHE estate: the estate-level decisions in
`decisions/`, the estate index `ESTATE.md`, which the `khe-workspace`
`AGENTS.md` points to, and `metrics/agent-loop.json`, the agent loop's counts
that `khe-sites` shows on `/agents/`
([ADR-044](decisions/044-agent-loop-numbers-are-a-counts-only-snapshot-here.md)).
Markdown, one generated JSON file and one check script; no build. Why this is
a repo of its own: [ADR-012](decisions/012-estate-architecture-is-public.md).

## Command

`bash scripts/check.sh` checks every ADR's format, length, links and
forbidden patterns, every relative link in `ESTATE.md`, and that
`metrics/agent-loop.json` has exactly the keys khe-workspace
`scripts/agent-metrics.sh` lists beside its `--json` writer, with whole
counts. It prints one
line per problem and exits 1 if it printed anything. CI runs it on every
push and pull request to `main`; the workspace commit gate runs it before
each commit.

Automated writers
([estate ADR-007](decisions/007-automated-writers.md)): Renovate automerges
GitHub Actions minor and patch updates, digests and pins (`renovate.json`)
once a release is three days old.
The workspace agent's weekly refresh (khe-workspace's `agent-metrics` skill)
pushes `metrics/agent-loop.json` to `main` with the fixed message
"agent-loop numbers" when a count changed (`scripts/agent-metrics.sh
--json`); its review skip is the one ADR-044 point 4 names. Nothing here
deploys; `khe-sites` builds the architecture page from this repo at its next
deploy. The way back from a bad automerge is to revert its
commit on `main` and push.

## Rules

1. **Everything here is public.** Nothing identifying (addresses, device
   identifiers, people, accounts) and no list of open weaknesses. The
   private working layer is `khe-meta` (roadmap, plans, house
   documentation); nothing here links into it or depends on it.
2. **Estate-level ADRs only.** A decision belongs here when it is hard to
   reverse, picks between real alternatives, and affects two or more repos
   or decides which repo owns a concern: all three. Not an estate ADR: an
   exception to an estate rule (a point of that rule's ADR), one repo's
   design (that repo's `docs/decisions/`, which keeps the same heading and
   status pattern), one machine's set-up (its runbook), an
   agent convention (`AGENTS.md` or `CLAUDE.md` in `khe-workspace`).
3. **Format.** Michael Nygard: a
   `# ADR-<number as in the file name>: <Title stating the decision>`
   heading, a
   `- **Status:** <Proposed|Accepted|Superseded|Moved|Deprecated> (<YYYY-MM-DD>)`
   bullet on line 3, optional `**Supersedes:**`, `**Superseded by:**`,
   `**Moved to:**` and `**Related:**` bullets, then the sections
   `## Context`, `## Decision`, `## Alternatives considered` (optional),
   `## Consequences` and `## References` (optional). Files are
   `decisions/NNN-slug.md`; numbers are not reused. A decision no longer in
   force here is a stub: the heading as it was, the Status line and one
   `**Superseded by:**` link to its successor or `**Moved to:**` naming its
   new home (a link to a public repo, a private one in prose), and no
   sections.
4. **Amend in place, stub on a reversal or a move.** An extension,
   narrowing or exception edits the ADR in place and moves its Status date
   to that day; git holds the earlier text. A reversal gets a new ADR, and
   the old one becomes a `Superseded` stub. A decision that leaves for one
   repo's docs becomes a `Moved` stub. An ADR states a decision and its
   reasons, never an inventory of current state; inventories live in the
   docs of the repo that implements them.
5. **Writing rules.** At most 90 lines, no exception. The Decision section
   names no paths, flags, key or host lists, timings or setup steps; it
   links the doc that holds them. Voice "we", "agent" only where the agent
   is the subject of the decision; no commit hashes, CI run ids, update
   notes, provenance, roadmap section numbers, paths into khe-meta (its
   plans or house documentation are named in prose) or links to khe-meta
   docs; other public repos by GitHub URL. A point number cited elsewhere
   ("ADR-004 point 5") keeps its number: a point whose content moves out
   shrinks to `N. Moved to <doc>.`, and new points are appended.
6. **Citations.** Other repos cite an ADR here as "estate ADR-NNN", with a
   GitHub link in Markdown docs, so a later move needs no sweep.
7. **A repo joining or leaving the estate** updates `ESTATE.md` here in the
   same change, and `repos/repos.yaml` in the `khe-workspace` repo; only
   khe-workspace itself, `khelias` and `khelias/.github`, which are not
   cloned into `repos/`, stay out of it.

All content in English.
