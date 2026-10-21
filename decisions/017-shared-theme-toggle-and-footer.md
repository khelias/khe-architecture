# ADR-017: The shared UI package carries the theme toggle and the site footer

- **Status:** Accepted (2026-10-20)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-015](015-family-design-layer.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-018](018-rooms-menu-in-the-shared-header.md)

## Context

[ADR-015](015-family-design-layer.md) gave every room a light and a dark
theme following the system setting and let a room offer its own control to
override it. We want one switch in every room's header that offers it,
beside the language switcher. Today only `khe-trips` has an override, and
its rules (where the choice is stored, when it clears, how the page shows
it) live inside that app, so a second room would copy them.

The site footer is built three times, in `khe-sites`, `khe-ai-adventure`
and `khe-study`, and the copies have drifted: icons in one, a hosting line
naming Tallinn in two, English only in one. That is the trigger
[ADR-014](014-shared-ui-packages.md) names for a shared component.

ADR-014 allows a shared package to hold presentation only: no app state and
no runtime or business library. A stored theme choice is state of a kind,
so we have to say on which side of that line it falls.

## Decision

1. **Which theme a visitor sees is presentation.** The shared package may
   hold the theme rules and the control, as it holds the header. App state
   stays the data an app owns: its trips, its locale, its URL.
2. **The family theme rule.** A page follows `prefers-color-scheme`. A
   manual override is stored per site under a key the consumer names; a
   choice equal to the system setting clears it. The override is
   `data-theme` on `<html>`, applied before first paint.
3. **A room that offers an override control (ADR-015 Decision 2) uses the
   shared toggle**, in the header next to the language switcher. A room
   committed to one theme, or not yet offering both, shows none and says so
   in its `AGENTS.md`. `khe-sites` and `khe-trips` offer it; the
   adventure game (dark by design), the study games (light only for now)
   and the 3D house demo (dark until it has a light theme) do not.
4. **The site footer is a package component.** The package owns its
   anatomy; the app passes the links, the privacy URL and the lines. Every
   room with a footer shows GitHub, LinkedIn, Privacy and the hosting line
   in the active language. `khe-trips` has no footer for now: whether its
   demo and shared trips get one is a design call for that room.
5. **The hosting line "Self-hosted in Estonia" stays** under
   [ADR-016](016-static-fallback-at-the-edge.md): the homelab serves every
   request while it is up, and the edge copy is only a fallback.

ADR-014 and ADR-015 stand otherwise.

## Alternatives considered

- **Copy the trips rules into `khe-sites`:** two copies of the same rules,
  which drift as the headers did.
- **The package ships the button and each app keeps the behaviour:** the
  rules are still copied into each app that offers the toggle.
- **One stored choice for every room:** `trips.khe.ee` and `games.khe.ee`
  are other origins than `khe.ee`, so a shared choice could only ever be
  partial.
- **Footers per app with a shared wording in `DESIGN.md`:** what we had in
  effect, and the footers drifted.
- **A custom element:** rejected in ADR-014 for the header, for the same
  reasons here.

## Consequences

- [`khe-ui`](https://github.com/khelias/khe-ui) gains a small behaviour
  module and a second component and stays free of runtime dependencies. A
  change to either is a `khe-ui` release plus one pull request per app.
- The script that applies the stored choice before first paint is inline
  in each page's head, so a content security policy without
  `'unsafe-inline'` would need its hash.
- The favicon still follows the system setting: it cannot read the page's
  override.
- If the edge ever serves first, the hosting line is revisited.
