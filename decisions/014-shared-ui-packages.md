# ADR-014: App repos move their stacks independently and may share versioned UI packages

- **Status:** Accepted (2026-10-17)
- **Supersedes:** [ADR-002](002-independent-stacks.md)
- **Related:** [ADR-001](001-repo-per-product.md), [ADR-003](003-adventure-proxy-stays-adventure-only.md), [ADR-008](008-container-images.md), [ADR-015](015-family-design-layer.md)

## Context

[ADR-002](002-independent-stacks.md) let each app repo move its stack on its
own schedule and ruled out shared code packages: a shared package would tie
the apps' releases together, and a component rebuilt in each repo was the
accepted cost. It named its own revisit trigger, the same component being
rebuilt in each repo.

That has happened with the site header. `khe-sites`, `khe-study`,
`khe-ai-adventure` and `khe-trips` each build the same anatomy: a KHE.ee
brand link, an optional kicker over a title, and an ET/EN switcher. The
defects were copied with it. When `khe-sites` fixed kicker and button
contrast, a brand suffix too small to read, font weights above the loaded
face and a misplaced navigation label, the three apps kept all of them.

The coupling argument holds only if one release reaches every app at once.
A package that is published with a version, pinned in each app and offered
to each app as its own update, merged on that app's schedule, does not
reach anyone uninvited. The apps keep their own palettes and read as one
family through shared anatomy, so what is shared is structure and
behaviour, and each app sets the colours.

## Decision

1. **Each app repo upgrades its stack on its own schedule.** Renovate keeps
   each one current; nothing waits for the others. Being on the same versions
   is welcome and is not a goal.
2. **A shared UI package is allowed** when it lives in its own repo, is
   published with semver, and each app pins it and merges its own bump:
   Renovate never automerges it in an app. It holds presentation only: no
   app state, no runtime or business library. That part of ADR-002 stands,
   and [ADR-003](003-adventure-proxy-stays-adventure-only.md) on the
   adventure proxy is unaffected.
3. **The shared site header lives in
   [`khe-ui`](https://github.com/khelias/khe-ui), published to npmjs as
   `@khelias/ui`.** A workflow on a GitHub-hosted runner publishes a tagged
   version through npm trusted publishing (OIDC) with provenance; no
   long-lived token is stored anywhere. Each app styles it through CSS
   custom properties.
4. **What is shared without a package stays shared as docs:** design docs
   (a `DESIGN.md` per repo), contracts (the JWT contract of
   [ADR-004](004-app-backend-and-identity.md), OpenAPI) and platform
   conventions ([ADR-008](008-container-images.md)). A doc is not a package,
   so it does not couple releases.
5. **A temporary difference is written where an agent will read it:** the
   repo's `AGENTS.md`.

## Alternatives considered

- **Keep rebuilding per repo:** the cost ADR-002 accepted. Rejected now
  that four copies exist and a fix in one has not reached the others.
- **Hand copies with a drift check:** each repo keeps a copy and a test
  compares it with a reference. Every fix is still four hand edits, and the
  four stacks (one with no bundler, one on Tailwind) make the copies differ
  in form, so the check compares little.
- **GitHub Packages as the registry:** it needs a token to install even a
  public package, in every app's CI, the homelab deploy runner and a fresh
  machine. npmjs installs a public package without one.
- **A custom element:** one renderer for every stack, but the header would
  render only after a script runs, the static site would need a client-side
  script it does not have today, and server-side markup would differ from
  the hydrated one. Light-DOM markup from a string renderer and a React
  component avoids all three.
- **A monorepo with the apps and the package:** ruled out by
  [ADR-001](001-repo-per-product.md).

## Consequences

- A header change is a `khe-ui` release plus one reviewed pull request per
  app. An app that does not merge it stays on its pin.
- The package stays on 0.x until all four apps run it, then goes to 1.0.0.
  Each app's Renovate config carries a rule that turns automerge off for
  `@khelias/ui`, because the general rules automerge patches and, from
  1.0.0, minors.
- An agent still does not port a pattern from one app repo to another
  without checking the target's versions; the package declares the React
  major it supports as a peer dependency.
- Each repo carries its own Renovate config and its own upgrade work.
- Revisit when a package forces apps to move together, for example a
  release that only works with a stack upgrade in every app.
