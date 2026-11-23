# ADR-035: The family covers the application shell, a design check enforces it, and named rooms keep their own look

- **Status:** Accepted (2026-11-23)
- **Supersedes:** [ADR-021](021-family-shell-and-design-check.md), [ADR-025](025-the-house-dashboard-keeps-its-own-look.md), [ADR-028](028-the-stories-room-keeps-its-own-look.md), [ADR-030](030-the-portfolio-frame-and-the-product-view.md), [ADR-032](032-unejanku-owns-its-header-and-footer.md)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)

## Context

The shared chrome reads as one family, but the rooms behind it read as
generated (gradients, shadows, large radii, default colours, emoji), and a
rule in a document is skipped by the next agent, so it needs a check. A few
rooms are better outside it: the house dashboard, the stories room and the
two games, plain or generic in the family values, Unejänku's children's
build, and a product opened directly.

## Decision

1. **The shared chrome, the khe.ee pages (the games hub and the house
   demo's frame included) and every room's shell use the family values and
   rules:** a room's ground, type, surfaces, controls, dialogs,
   notifications, menus and lists around its content. Each room has one
   accent, in the mark's `.ee` and as its rooms-list dot. Play areas,
   canvases, maps and the house drawing keep their own look within the
   check's ratchet (point 8); state colour is meaning, not an accent.
   Points 9 to 13 name the exceptions.
2. **Every room has a light and a dark theme following the system
   setting.** A room may commit its content to one theme, which its header
   then takes, marked on `<html data-theme>`, and may offer an override.
3. **[`khe-sites`](https://github.com/khelias/khe-sites) owns the family
   `DESIGN.md`**, the one source of the family values; other repos keep
   only their room in their own design docs and cite it.
4. **The room accents are defaults in the shared header package,** since
   every header shows them all. The other values reach the apps as the
   header's custom properties ([ADR-014](014-shared-ui-packages.md)), and a
   check in `khe-sites` compares the package's copy with `DESIGN.md`.
5. **A room off the rule says so in its `AGENTS.md`**, citing any exception.
6. **The header names the room in a rooms menu.** The mark leads to the
   khe.ee front page; every other page shows the room's name (and an app's
   after a slash) as a button that opens every room with its dot and note,
   on a product page in its frame view only (points 11 and 12).
7. **The room list lives in [`khe-ui`](https://github.com/khelias/khe-ui)
   and is presentation** under ADR-014 point 2, as the theme is (ADR-014
   point 6): navigation chrome, not app state.
8. **`@khelias/ui` carries a design check of presentation rules,**
   presentation under ADR-014 point 2. Every web app lints with it against
   a committed baseline that only shrinks; a line may opt out with a reason
   ([khe-ui `AGENTS.md`](https://github.com/khelias/khe-ui/blob/main/AGENTS.md)).
   An excepted room's `AGENTS.md` says what of it the check reads.
9. **Home Assistant's dashboard keeps its own look** (glass, blur, gradients,
   its own controls); the house demo's frame around it follows point 1.
10. **The stories room's content keeps its own look** on both builds
    ([ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)):
    system type, a reading serif, large radii, translucent materials, no check.
11. **A product page has two views.** The KHE header is the portfolio
    frame, always on khe.ee pages, the games hub and the demos. A product
    page shows it for a visit from a frame page; otherwise, and always when
    installed, the product view: its own title, theme toggle and language
    switcher, and a khe.ee link in the footer, decided by the shared
    package before first paint. A demo's frame has a neutral line on what
    it shows and keeps private, with a link on for the family
    ([khe-ui ADR-006](https://github.com/khelias/khe-ui/blob/main/docs/adr/006-the-demo-line-links-the-real-site.md)).
12. **Unejänku's family build draws its own header and footer** (its mark,
    name and language switch; the voice credit, privacy notice and a khe.ee
    link) as app markup outside points 1, 6 and 8, with no theme toggle in
    its night theme. The public build keeps the family's, setting their
    custom properties over its sky. The language switch lives only in the
    header, the credit only in the footer.
13. **In the study and adventure rooms everything below the header is
    content and keeps its own look,** set in each repo's design docs.

## Alternatives considered

- **A stricter `DESIGN.md`, a gate script or Stylelint:** agents skip
  documents, no CI runs a gate script, and Stylelint adds dependencies and
  has no rule for emoji or dashes.
- **Fix every room at once:** the ratchet stops them getting worse instead.
- **Always hide the header on products, or a parameter on frame links:** a
  visitor loses the way between rooms, or a copied link opens the frame.

## Consequences

- A new room, accent or check rule is a `khe-ui` release plus each app's
  bump, which may raise a baseline; it does not reach Unejänku's family build.
- The check reads source, not rendering, so a centred hero stays for review,
  as does `khe-home-assistant`, which has no npm project.
- Excepted rooms can drift from the family and honour reduced transparency
  and motion. Without a referrer a browser gets the product view, without
  the Popover API the mark and no menu.
- Revisit when a room needs its own menu links, the rooms outgrow a list, or
  two rooms need the same state colours (then shared tokens).
