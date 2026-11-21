# ADR-019: khe-sites owns the analytics consent banner, and the games load it from the origin root

- **Status:** Accepted (2026-11-21)
- **Supersedes:** [ADR-045](045-khe-ee-pages-from-other-repos-load-the-consent-banner-unstamped.md)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md)

## Context

The analytics consent banner existed three times: in
[`khe-sites`](https://github.com/khelias/khe-sites), which serves khe.ee
and the games.khe.ee hub, and as a copy in each of
[`khe-study`](https://github.com/khelias/khe-study) and
[`khe-ai-adventure`](https://github.com/khelias/khe-ai-adventure). A
change to it had to be made three times, and the copies had drifted apart
in look and wording.

The banner stores the visitor's choice in the browser, per origin, and
loads a third-party analytics beacon only after consent. The games are
paths of games.khe.ee, whose root is the `khe-sites` hub, so the hub and
both games already share one choice and one privacy page. The games set
their own theme but do not define the family's custom properties, so a
banner that reads them renders without a ground there.

Some public khe.ee pages are built outside `khe-sites`: the published
stories by [`khe-stories`](https://github.com/khelias/khe-stories) and the
trip demo and shared trips by `khe-trips`. `khe-sites` pages load the banner
with a content hash, so a change reaches them at once; another repo's build
cannot see that hash without reading the other repo's build or the live site.

## Decision

1. **`khe-sites` owns the banner** and serves it from the root of both its
   origins, khe.ee and games.khe.ee.
2. **A page under games.khe.ee loads it from that root**, configured on its
   script tag, and keeps no copy of its own.
3. **The banner carries its own family values in light and dark** and
   follows the page's theme
   ([ADR-035](035-family-shell-and-design-check-with-its-exceptions.md)
   point 2), else the system setting, so it renders on a page that does not
   define the family tokens.
4. **Its storage key, its script API and its preferences hook are a
   contract `khe-sites` keeps.** A breaking change to any of them is served
   at a new path, and the consumers move to it. The path, the attributes
   and the contract are in
   [khe-sites `AGENTS.md`](https://github.com/khelias/khe-sites/blob/main/AGENTS.md).
5. **A public khe.ee page built by another repo loads the banner unstamped**
   from the khe.ee root, as a game page does under points 2 to 4, and keeps
   no copy. `khe-sites` lists each such consumer in its own docs. A build
   behind Access loads no banner and no beacon.

## Alternatives considered

- **`@khelias/ui`** ([ADR-014](014-shared-ui-packages.md)): each app
  merges its own pin, so one origin would show two versions of the banner
  while one consent choice covers them all. The banner stores a choice and
  loads a third-party script, beyond the presentation a package may hold.
  Revisit when a page on an origin `khe-sites` does not serve needs it: the
  source then moves to the package and each origin's owner serves one copy.
- **Copies with a drift check, or a build step copying the file:** every
  change is still made in each repo, or the builds couple across repos.
- **Stamping it in other repos' builds:** they would fetch the live banner
  or read a `khe-sites` checkout, for a banner that rarely changes.
- **A shorter cache on the banner's path:** every khe.ee page would fetch
  it more often to serve a few rarely visited ones.

## Consequences

- A banner change is one `khe-sites` deploy. Its own pages see it at once;
  unstamped pages see it within their origin's browser cache, hours on the
  games origin and weeks on khe.ee. An old copy keeps working until then,
  since a breaking change goes to a new path.
- One consent choice per origin: a visitor who answered on any khe.ee page
  is not asked again on the others.
- The pages depend at runtime on the `khe-sites` build at their origin's
  root. When the file is missing, the root answers its HTML fallback, the
  browser refuses it as a script, and the page shows no banner and loads no
  beacon: it fails toward privacy.
- The edge copy ([ADR-016](016-static-fallback-at-the-edge.md)) carries
  the banner with the hub root.
- A page on another origin, such as the trip atlas, needs its own decision.
  The game dev servers and tests get the file from elsewhere, each game's
  concern.
