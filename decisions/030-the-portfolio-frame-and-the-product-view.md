# ADR-030: The portfolio frame and the product view

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-017](017-shared-theme-toggle-and-footer.md), [ADR-021](021-family-shell-and-design-check.md) (replaces point 6 on product pages), [ADR-028](028-the-stories-room-keeps-its-own-look.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (product view only on stories.khe.ee), [ADR-034](034-the-demo-line-links-the-real-site.md) (replaces point 4), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md)

## Context

[ADR-021](021-family-shell-and-design-check.md) point 6 puts the KHE
header on every page but the khe.ee landing: the KHE.ee mark, the room's
button and the rooms list. Two things do not fit it.

The demos do not say they are demos. `khe.ee/ha/` shows a made-up house,
`khe.ee/trips/` opens one trip of many and `khe.ee/stories/` a few stories
of the collection. Only the trips demo says so, in a line on its own
landing.

The header is portfolio chrome. While someone browses the portfolio it
helps them move between rooms. A child opening Tarkade mängud from a
teacher's link, or the stories app from the home screen, is using a
product and needs none of it. How the visit started tells the two apart:
from a khe.ee page or the games hub the frame belongs; opened directly
(a shared link, a bookmark, the installed app) the product belongs.

Every site sends `Referrer-Policy: strict-origin-when-cross-origin`, so a
click from khe.ee to games.khe.ee arrives with the origin and a
same-origin click with the full address. In every product app the header
holds the only language switcher, and in some the only theme toggle, so a
product still needs a header of its own.

## Decision

1. **The KHE header is the portfolio frame.** khe.ee pages, the
   architecture and agents pages, the games hub and the demos always show
   it.
2. **A product page has two views.** It shows the frame when this tab
   arrived from a frame page, and keeps that for the tab in
   `sessionStorage` until 30 minutes pass without a page load there, the
   usual length of a web visit, so a long-lived tab returns to the product
   view. A frame page is any page on the product's own origin outside its
   path, or on `https://khe.ee/` or `https://games.khe.ee/`. Otherwise,
   and always when it runs installed (`display-mode: standalone`, iOS
   `navigator.standalone`), it shows the product view: the app's own
   title, the theme toggle and the language switcher; no mark, no rooms,
   no demo line. The footer then carries a KHE.ee link.
3. **The decision is made before first paint** by an inline script from
   `@khelias/ui` in [`khe-ui`](https://github.com/khelias/khe-ui), which sets `data-khe-view="product"` on `<html>`; the
   header's CSS shows one view or the other. Both views are in the markup,
   so nothing renders after load.
4. **A demo carries a demo line** under the header in the frame view:
   "Demo" and one sentence on what the demo shows and what stays private.
   It is neutral, with no room accent, and part of the header, so it stays
   with it.
5. **The view decision counts as presentation** under
   [ADR-014](014-shared-ui-packages.md) point 2, as the stored theme choice
   does under [ADR-017](017-shared-theme-toggle-and-footer.md) point 1: it
   reads the referrer and a per-tab time and sets one attribute on
   `<html>`, no app state.

## Alternatives considered

- **Always hide the header on products:** a visitor browsing the
  portfolio loses the way back and between rooms, which is what the frame
  is for.
- **A `?from=khe` parameter on the frame's links:** it sticks to every
  link copied from the address bar, so a shared link would open the frame.
- **A separate product header component:** two headers to keep in step,
  and the choice between them would be made after load, or in every app
  on its own.

## Consequences

- khe-study and khe-ai-adventure keep the frame on every page until they
  move to the product view with their next `@khelias/ui` bump; the first
  product pages are the stories room and its app.
- A shared link to `khe.ee/stories/` opens the product view, so it shows
  no demo line; the demo line is for visitors who came through the
  portfolio.
- A browser that strips the referrer shows the product view, the safe
  side: the page works and only the portfolio frame is missing.
- The privacy page names the per-tab key, and that the page reads where
  the visit came from without sending it anywhere.
