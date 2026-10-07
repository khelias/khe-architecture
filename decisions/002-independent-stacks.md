# ADR-002: App repos move their stacks independently; no lockstep, no shared code packages

- **Status:** Accepted (2026-05-03)

## Context

When this was decided the estate had three app repos, `khe-study`,
`khe-ai-adventure` and `khe-trips`, with more to come; each is its own repo
([ADR-001](001-repo-per-product.md)). They use the same kind of frontend
stack: React, Vite, Tailwind and TypeScript. That raises two questions: do
they upgrade in lockstep, and do they share code such as a UI component
library?

A shared package, or a lockstep upgrade, ties the apps' release and deploy
cycles together: one app's upgrade waits for the others, and a change in the
shared code ships into every app at once. When this was decided the apps
were also on different majors of TypeScript, Vite, Tailwind and their state
library, so lockstep would have cost several evenings of migrations first.

The apps are still meant to read as one family, so something has to be
shared.

## Decision

1. **Each app repo upgrades its stack on its own schedule.** Renovate keeps
   each one current; nothing waits for the others. Being on the same versions
   is welcome and is not a goal.
2. **No shared code packages between app repos,** neither a UI component
   library nor a shared runtime library. A component rebuilt in each repo is
   the accepted cost.
3. **What may be shared is not code:** design docs (a `DESIGN.md` per repo),
   contracts (OpenAPI, the JWT contract proposed in
   [ADR-004](004-app-backend-and-identity.md)), and platform conventions
   ([ADR-008](008-container-images.md)). A doc is not a package, so it does
   not couple releases. The two planned backends follow the same line in two
   languages ([ADR-009](009-backend-language-per-app.md)): what is shared is
   a contract and a platform, not code.
4. **A temporary difference is written where an agent will read it:** the
   repo's `AGENTS.md`.

## Alternatives considered

- **Lockstep:** bring all apps into sync and keep them there. Rejected on
  cost at first, and on coupling once the versions had converged on their
  own.
- **A shared UI library:** rejected for the same coupling.

## Consequences

- An agent does not port a pattern from one app repo to another without
  checking the target's versions.
- Each repo carries its own Renovate config and its own upgrade work.
- The AI proxy question is the same question for a service:
  [ADR-003](003-adventure-proxy-stays-adventure-only.md).
- Revisit the shared UI library if the same component keeps being rebuilt in
  each repo.
