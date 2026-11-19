# ADR-045: khe.ee pages built by other repos load the consent banner unstamped

- **Status:** Accepted (2026-11-19)
- **Related:** [ADR-019](019-consent-banner-from-the-origin-root.md) (extends: an unstamped consumer on khe.ee), [ADR-013](013-trips-public-demo.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)

## Context

[`khe-sites`](https://github.com/khelias/khe-sites) serves the analytics
consent banner at `/assets/analytics-consent.js` on khe.ee, and its own
pages load it with a content hash in the URL, so a banner change reaches
them at once. ADR-019 let the games.khe.ee pages load it unstamped, and
said a page on khe.ee that cannot stamp it needs its own decision, since
the khe.ee root serves the file with a 30-day browser cache.

Some public khe.ee pages are built outside `khe-sites`: the published
stories at `khe.ee/stories/` by
[`khe-stories`](https://github.com/khelias/khe-stories), and the trip demo
at `khe.ee/trips/` and the shared trips at `khe.ee/r/<slug>/` by
[`khe-trips`](https://github.com/khelias/khe-trips). The stories page
already loads the banner unstamped; the trip pages load none, so their
visits are not counted. A stamp needs the hash of the file `khe-sites`
last built, which those builds cannot see without reading the other
repo's build or the live site.

## Decision

1. **A khe.ee page built by another repo loads the banner unstamped** from
   the root, `<script async src="/assets/analytics-consent.js">`, with the
   khe.ee `data-analytics-token` and a `data-analytics-privacy-url` on
   `/privacy`, and keeps no copy. ADR-019 points 2 to 4 apply to it as to a
   game page.
2. **`khe-sites` lists each such consumer** in its own docs beside the
   games, so a banner change knows which pages it reaches late.
3. **Only public pages load it.** A build that stays behind Access, such as
   the trip atlas or the family stories, loads no banner and no beacon.

## Alternatives considered

- **Stamp it at build time:** the other repo's build would fetch the live
  banner or read a `khe-sites` checkout to compute the hash, which couples
  the builds across repos for a banner that rarely changes.
- **A copy in each repo:** the drift ADR-019 removed.
- **A shorter cache on the banner's path:** every khe.ee page would fetch
  it again more often to serve a few pages that are rarely visited.

## Consequences

- A banner change reaches these pages within the browser's 30 days. A
  breaking change already goes to a new path (ADR-019 point 4), so an old
  copy keeps working until then.
- The consent choice is the one khe.ee choice: a visitor who answered on
  any khe.ee page is not asked again on these.
- When the file is missing, the page shows no banner and loads no beacon,
  as ADR-019 says for the games.
