# ADR-019: khe-sites owns the analytics consent banner, and the games load it from the origin root

- **Status:** Accepted (2026-10-21)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-017](017-shared-theme-toggle-and-footer.md), [ADR-018](018-rooms-menu-in-the-shared-header.md)

## Context

The analytics consent banner existed three times: in
[`khe-sites`](https://github.com/khelias/khe-sites), which serves khe.ee
and the games.khe.ee hub, and as a copy in each of
[`khe-study`](https://github.com/khelias/khe-study) and
[`khe-ai-adventure`](https://github.com/khelias/khe-ai-adventure). A
change to it, such as giving Allow and Decline equal weight, had to be
made three times, and the copies had already drifted apart in look and in
wording.

The banner stores the visitor's choice in the browser, per origin, and
loads a third-party analytics beacon only after consent. The games are
paths of games.khe.ee (`/study`, `/adventure`), whose root is the
`khe-sites` hub, so the hub and both games already share one choice and
one privacy page. The games set their own theme on `<html data-theme>`
but do not define the family's custom properties on the page, so a banner
that reads them renders without a ground there.

## Decision

1. **`khe-sites` owns the banner** and serves it at
   `/assets/analytics-consent.js` on both its origins, khe.ee and
   games.khe.ee.
2. **A page under games.khe.ee loads it from that root path**, configured
   by the `data-analytics-token` and `data-analytics-privacy-url`
   attributes on its script tag, and keeps no copy of its own.
3. **The banner carries its own family values in light and dark** and
   follows the page's `<html data-theme>`
   ([ADR-018](018-rooms-menu-in-the-shared-header.md) point 2), else the
   system setting, so it renders on a page that does not define the family
   tokens. ADR-018 point 4, the family values as the shared header's custom
   properties, stands for the header.
4. **Its storage key, the `window.kheAnalyticsConsent` API and the
   `[data-analytics-preferences]` hook are a contract `khe-sites` keeps.**
   A breaking change to any of them is served at a new path, and the
   consumers move to it.

## Alternatives considered

- **`@khelias/ui`** ([ADR-014](014-shared-ui-packages.md)): each app
  merges its own pin, so one origin would show two versions of the banner,
  with different wording or behaviour, until every app caught up, while one
  consent choice covers them all. The banner stores a choice and loads a
  third-party script, which is beyond the presentation ADR-014 allows a
  package, and each change would be a release plus three bumps. Revisit
  when a page on an origin `khe-sites` does not serve needs the banner:
  the source then moves to the package and each origin's owner serves one
  copy at its root, so one version per origin still holds.
- **Copies with a drift check:** ADR-014's own reasons against copies; the
  check finds drift but every change is still made three times.
- **A build step copying the `khe-sites` file into each game:** couples
  the builds across repos and still needs one deploy per game for a change.

## Consequences

- A banner change is one `khe-sites` deploy. Its own pages load it stamped
  and see it at once; the game pages load it unstamped and see it within
  the games origin's four-hour cache.
- An unstamped consumer on khe.ee would wait out that origin's 30-day
  cache, so a page there loads it stamped or gets its own decision. A page
  on another origin, such as the trip atlas, needs its own decision.
- The games depend at runtime on the `khe-sites` build being at the
  games.khe.ee root, as they already do for `/privacy`. When the file is
  missing, the root answers its HTML fallback, the browser refuses it as a
  script, and the game shows no banner and loads no beacon: it fails
  toward privacy.
- The edge copy ([ADR-016](016-static-fallback-at-the-edge.md)) carries
  the banner with the hub root; nothing changes there.
- The game dev servers and test runs need the file from somewhere else
  than their own build; how is each game's concern.
