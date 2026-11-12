# ADR-024: Each agent rule has one home; every other file cites it

- **Status:** Accepted (2026-11-12)
- **Related:** [ADR-001](001-repo-per-product.md), [ADR-007](007-automated-writers.md), [ADR-012](012-estate-architecture-is-public.md), [ADR-021](021-family-shell-and-design-check.md), [ADR-023](023-agent-pushes-where-its-session-allows.md)

## Context

- The AI coding agent reads instructions from several files: the
  workspace's `AGENTS.md` (every agent, every session), its `CLAUDE.md`
  (Claude only, with the harness that enforces the rules), and one
  `AGENTS.md` per repo.
- Sessions start at the workspace root in practice, so the workspace files
  are loaded almost always. A session started inside one repo sees only that
  repo's file.
- The workspace had a rule that an estate ADR that becomes Accepted puts its
  rule into the `AGENTS.md` of every repo whose work it constrains, because
  agents read those files, not the ADRs. Over time the same sentence came to
  stand in up to nine files: the writer register of ADR-007, the usage of
  the design check of ADR-021, the fork PR approval of ADR-023, the backend
  pattern of ADR-004. The workspace files also repeated each other.
- ADR-023 alone touched the workspace files, two skills, six repo files and
  the public pages. Every copy is a place that drifts when the rule changes,
  and an agent cannot tell which copy is current.

## Decision

1. **Each rule has one home.**
   - The decision and its reasons: the estate ADR.
   - The agent's workspace-wide behaviour (push and review routes, docs,
     boundaries, estate ADRs in general): the workspace `AGENTS.md`.
   - Facts about the Claude harness (the commit gate, the sandbox, skills):
     the workspace `CLAUDE.md`.
   - The usage of a shared tool: the `AGENTS.md` of the repo that owns it,
     such as the design check in `khe-ui` and VM operations in
     `khe-homelab`.
   - Setting up a repo (rulesets, runners, pin apps): "Adding a repo" in
     this repo's `ESTATE.md`.
2. **A repo's `AGENTS.md` holds only what is particular to it.** It opens
   with one line pointing to the workspace `AGENTS.md`, cites an estate ADR
   as "estate ADR-NNN" with a link, and states only its own instance of the
   rule: a path, an exemption, a check, a deviation, what automerges there
   and its way back.
3. **An estate ADR that becomes Accepted updates the one home of its rule**,
   and a repo's `AGENTS.md` only where something particular to that repo
   changes. Agents still learn rules from these files rather than from the
   ADRs; they find them in the workspace files every session loads.
4. **What ADR-001 and ADR-021 point 5 put into a repo's `AGENTS.md`** (its
   own conventions, a room that does not meet the family rule yet) is a
   repo-particular fact and stays there. This ADR overrides no Accepted
   ADR.

## Alternatives considered

- **Keep copying every Accepted rule into each repo's file.** A repo opened
  on its own carries its rules, but every decision becomes a sweep across
  the estate and the copies drift.
- **No estate citations in repos at all.** The shortest files, but a repo
  fact loses the trail to its reason, and the next change to it cannot tell
  whether the fact is local or estate-wide.

## Consequences

- A decision touches the file that owns its rule plus the repos where a
  particular fact changes, not every repo it constrains.
- A session opened inside a single repo sees only that repo's file and its
  pointer; it has to be started from the workspace root to act under the
  workspace rules.
- A rule that turns out to differ per repo is split back: the shared part
  stays in its home, the particular part goes to the repo.
- The public description of the agent's loop changes only when a decision
  does, not when a rule moves between files.
