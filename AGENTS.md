# khe-architecture

The public architecture of the KHE estate: the estate-level decisions in
`decisions/` and the estate index `ESTATE.md`, which the `khe` workspace
`CLAUDE.md` imports. Markdown plus one check script; no build. Why this is
a repo of its own: [ADR-012](decisions/012-estate-architecture-is-public.md).

## Command

`bash scripts/check.sh` checks every ADR's format, length, links and
forbidden patterns, and every relative link in `ESTATE.md`. It prints one
line per problem and exits 1 if it printed anything. CI runs it on every
push and pull request to `main`; the workspace commit gate runs it before
each commit.

## Rules

1. **Everything here is public.** Nothing identifying (addresses, device
   identifiers, people, accounts) and no list of open weaknesses. The
   private working layer is `khe-meta` (roadmap, plans, house
   documentation); nothing here links into it or depends on it.
2. **Estate-level ADRs only.** A decision belongs here if it affects two or
   more repos or decides which repo owns a concern. In-repo decisions stay
   in that repo's `docs/adr/` or `docs/decisions/`, which keep the same
   heading and status pattern.
3. **Format.** Michael Nygard: a
   `# ADR-<number as in the file name>: <Title stating the decision>`
   heading, a
   `- **Status:** <Proposed|Accepted|Superseded|Deprecated> (<YYYY-MM-DD>)`
   bullet on line 3, optional `**Supersedes:**`, `**Superseded by:**` and
   `**Related:**` bullets, then the sections `## Context`, `## Decision`,
   `## Alternatives considered` (optional), `## Consequences` and
   `## References` (optional). Files are `decisions/NNN-slug.md`.
4. **An Accepted ADR is immutable.** Only its Status line, its Supersedes /
   Superseded by / Related bullets and a broken link may change; a changed
   decision gets a new ADR that supersedes it, and the old one becomes
   `Superseded` with a `**Superseded by:**` bullet. So an ADR states a
   decision and its reasons, never an inventory of current state;
   inventories live in the docs of the repo that implements them.
5. **Writing rules.** One page (at most 120 lines, 008 at most 150); voice
   "we", "agent" only where the agent is the subject of the decision; no
   commit hashes, CI run ids, update notes, provenance, roadmap section
   numbers, paths into khe-meta (its plans or house documentation are named
   in prose) or links to khe-meta docs; other public repos by GitHub URL.
   A point number cited elsewhere ("ADR-004 point 5") keeps its number.
6. **Citations.** Other repos cite an ADR here as "estate ADR-NNN", with a
   GitHub link in Markdown docs, so a later move needs no sweep.
7. **A repo joining or leaving the estate** updates `ESTATE.md` here in the
   same change, and `repos/repos.yaml` in the `khe` workspace repo.

All content in English.
