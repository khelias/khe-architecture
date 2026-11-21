# ADR-014: App repos move their stacks independently and may share versioned UI packages

- **Status:** Accepted (2026-11-21)
- **Supersedes:** [ADR-002](002-independent-stacks.md), [ADR-017](017-shared-theme-toggle-and-footer.md)
- **Related:** [ADR-001](001-repo-per-product.md), [ADR-003](003-adventure-proxy-stays-adventure-only.md), [ADR-008](008-container-images.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md), [ADR-041](041-installed-apps-stay-on-their-paths-with-a-worker-each.md) (the worker stays out of the shared package)

## Context

Each app repo moved its stack on its own schedule, with no shared code
packages: a shared package would tie the apps' releases together, and a
component rebuilt in each repo was the accepted cost until the same one was
rebuilt everywhere. That happened with the site header: four repos built the
same anatomy, and when `khe-sites` fixed its contrast and type defects, the
three app copies kept them all. The footer followed, built three times and
drifted in icons, wording and language, and the light and dark override
lived inside one app, whose rules a second room would have copied.

The coupling argument holds only if one release reaches every app at once.
A package published with a version, pinned in each app and merged on that
app's schedule reaches no one uninvited. What is shared is structure and
behaviour; each app sets the colours. A stored theme choice is state of a
kind, so it has to be placed on one side of the presentation line.

## Decision

1. **Each app repo upgrades its stack on its own schedule.** Renovate keeps
   each one current; nothing waits for the others. Being on the same
   versions is welcome and is not a goal.
2. **A shared UI package is allowed** when it lives in its own repo, is
   published with semver, and each app pins it and merges its own bump:
   Renovate never automerges it in an app. It holds presentation only: no
   app state, no runtime or business library.
   [ADR-003](003-adventure-proxy-stays-adventure-only.md) on the adventure
   proxy is unaffected.
3. **The shared site header lives in
   [`khe-ui`](https://github.com/khelias/khe-ui), published to npmjs as
   `@khelias/ui`** through trusted publishing with provenance and no stored
   token ([its release](https://github.com/khelias/khe-ui/blob/main/AGENTS.md)).
   Each app styles it through CSS custom properties.
4. **What is shared without a package stays shared as docs:** design docs,
   contracts (the JWT contract of
   [ADR-004](004-app-backend-and-identity.md), OpenAPI) and platform
   conventions ([ADR-008](008-container-images.md)). A doc does not couple
   releases.
5. **A temporary difference is written where an agent will read it:** the
   repo's `AGENTS.md`.
6. **Which theme a visitor sees is presentation.** The package may hold the
   theme rules and the override control, as it holds the header; app state
   stays the data an app owns. A page follows the system setting, and a
   manual override is stored per site and applied before first paint.
7. **The theme toggle and the site footer are package components.** A room
   that offers an override uses the shared toggle beside the language
   switcher; one that does not says so in its `AGENTS.md`. The package owns
   the footer's anatomy, and the app passes its links and lines.
8. **The footer's hosting line, "Self-hosted in Estonia", stays** under
   [ADR-016](016-static-fallback-at-the-edge.md): the homelab serves every
   request while it is up, and the edge copy is only a fallback.

## Alternatives considered

- **Keep rebuilding per repo, or hand copies with a drift check:** every
  fix is still four hand edits, and four stacks make the copies differ in
  form, so a check compares little.
- **GitHub Packages:** it needs a token to install even a public package,
  in every app's CI, the deploy runner and a fresh machine.
- **A custom element:** the header would render only after a script runs,
  the static site would need one, and server markup would differ from the
  hydrated one.
- **A monorepo with the apps and the package:** ruled out by
  [ADR-001](001-repo-per-product.md).
- **The package ships the toggle button and each app keeps the behaviour:**
  the rules are still copied into each app.
- **One stored theme choice for every room:** the rooms live on several
  origins, so a shared choice could only be partial.

## Consequences

- A header, toggle or footer change is a `khe-ui` release plus one reviewed
  pull request per app; an app that does not merge it stays on its pin.
- The package stays on 0.x until all four apps run it. Each app's Renovate
  config turns automerge off for it, since the general rules automerge
  patches and, from 1.0.0, minors.
- An agent does not port a pattern between app repos without checking the
  target's versions; the package declares its React major as a peer.
- The pre-paint theme script is inline, so a content security policy
  without inline scripts needs its hash; the favicon still follows the
  system setting.
- Revisit when a package forces apps to move together, or the hosting line
  when the edge ever serves first.
