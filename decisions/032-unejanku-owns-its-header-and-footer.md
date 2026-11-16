# ADR-032: Unejänku's family build draws its own header and footer

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-028](028-the-stories-room-keeps-its-own-look.md) (replaces point 2 on stories.khe.ee), [ADR-021](021-family-shell-and-design-check.md) (points 1, 6 and 8 do not apply to the family build's header and footer), [ADR-030](030-the-portfolio-frame-and-the-product-view.md) (point 2 on stories.khe.ee), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (point 6), [ADR-033](033-story-pictures-are-content.md), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md)

## Context

Unejänku has two builds from
[khe-stories](https://github.com/khelias/khe-stories): the family build at
`stories.khe.ee`, which the children and their parents use at bedtime, and
the public build at `khe.ee/stories/`
([ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)).
Both wear the family shell: the KHE header bar and the family footer with
its portfolio links, as
[ADR-028](028-the-stories-room-keeps-its-own-look.md) point 2 asks.

The family build only ever shows the product view (ADR-031 point 6), so the
header there carries no rooms menu and no mark, only a title and the
language switch, in the family's grey bar. The footer's GitHub and LinkedIn
links mean nothing to a child choosing a story. Redrawn as a night scene,
the app reads as a children's app until the frame starts and stops at its
edges; the shell is then the one part of the page that looks like a
portfolio.

The public build is a page of khe.ee, read by visitors who arrive from the
rest of the family, and its frame is what joins it to that family
([ADR-030](030-the-portfolio-frame-and-the-product-view.md) point 1).

## Decision

1. **The family build draws its own header and footer.** At
   `stories.khe.ee` the header is the app's: its mark, its name and the
   language switch. The footer holds the voice credit, the privacy notice
   and a link to khe.ee. They are app markup, rendered at build time like
   the rest of the page, and outside the design check like the story
   content (ADR-028 point 1). This replaces ADR-028 point 2 for
   `stories.khe.ee`.
2. **What the family build leaves of the family rules.** The header and
   footer there are not the shell of
   [ADR-021](021-family-shell-and-design-check.md) point 1, carry no rooms
   menu (point 6) and are not counted by the design check (point 8). The
   product view's own title and language switcher of ADR-030 point 2 are
   kept, now drawn by the app; the theme toggle goes, since the room is
   committed to its night theme.
3. **The public build keeps the family header and footer.** At
   `khe.ee/stories/` the shared header and footer stay, as ADR-028 point 2
   asks, with the frame and product views of ADR-030. The app may set the
   header's custom properties, such as a transparent background over its
   sky, as every room sets its own.
4. **One fact, one place.** The language switch lives only in the header,
   and the voice credit only in the footer of both builds; the line saying
   the voice is synthetic stays beside the player as well, as ADR-031
   point 9 asks.

## Alternatives considered

- **Keep the family shell in both builds:** the header and footer stay the
  only portfolio parts of a children's app that no visitor of the
  portfolio reaches.
- **Own header and footer in both builds:** the public build would leave
  the family a visitor arrived from, the frame ADR-030 is for.
- **A children's variant of the shared header in `@khelias/ui`:** a second
  header to version and release for one room, and the shared package would
  carry one app's look.

## Consequences

- A change to the shared header does not reach `stories.khe.ee`; the app's
  own header is kept in step with the app.
- The two builds look different at their edges; the story pages between
  them are the same.
- If the family later adopts the stories look, this exception can fold
  back into a shared header.
