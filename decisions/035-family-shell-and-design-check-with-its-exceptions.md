# ADR-035: The family covers the application shell, a design check enforces it, and named rooms keep their own look

- **Status:** Accepted (2026-11-17)
- **Supersedes:** [ADR-021](021-family-shell-and-design-check.md)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-017](017-shared-theme-toggle-and-footer.md), [ADR-025](025-the-house-dashboard-keeps-its-own-look.md), [ADR-028](028-the-stories-room-keeps-its-own-look.md), [ADR-030](030-the-portfolio-frame-and-the-product-view.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md), [ADR-032](032-unejanku-owns-its-header-and-footer.md), [ADR-049](049-the-familys-type-is-familjen-grotesk.md) (the family's typeface)

## Context

[ADR-021](021-family-shell-and-design-check.md) put every room's shell on
the family values and made a design check in the shared package enforce
it; its reasons stand there. Four later ADRs changed parts of it:
[ADR-025](025-the-house-dashboard-keeps-its-own-look.md) and
[ADR-028](028-the-stories-room-keeps-its-own-look.md) let two rooms keep
their own look, [ADR-030](030-the-portfolio-frame-and-the-product-view.md)
gave product pages a view without the rooms menu, and
[ADR-032](032-unejanku-owns-its-header-and-footer.md) gave the stories
family build a header of its own. ADR-021 still read Accepted, so its
reader had to assemble the rule from five ADRs. This ADR restates it with
the same point numbers, so a citation of "ADR-021 point N" reads as point
N here, and names each exception at its point without restating it.

## Decision

1. **Every room's shell uses the family values and rules.** The shell is
   the page ground, the type, the surfaces, the controls, dialogs,
   notifications, menus and lists around a room's content, as well as the
   shared chrome. Each room has one accent, shown in the chrome in the
   `.ee` of the mark and as each room's dot in the rooms list. Play areas,
   canvases, maps and the house drawing keep their own look, within the
   check's ratchet (point 8). State colour (on and off, ok, warning,
   fault, a map state, right or wrong) is meaning, not an accent, and a
   room may use several. Home Assistant's dashboard (ADR-025), the stories
   room's content (ADR-028 point 1, on `stories.khe.ee` too by
   [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)
   point 6) and the stories family build's header and footer (ADR-032)
   keep their own look; a product view (ADR-030 point 2) has no mark.
2. **Every room has a light and a dark theme following the system
   setting.** A room may commit its content to one theme when the subject
   asks for it, and its header then takes that theme. A room committed to
   one theme marks it on `<html data-theme>`, so the shared package's parts
   that follow the theme (the dots, the toggle icon) match it. A room may
   offer its own control to override the system setting.
3. **[`khe-sites`](https://github.com/khelias/khe-sites) owns the family
   `DESIGN.md`**, the one source of the family values: tokens in both
   themes, the rooms and the rules. Other repos keep only their room in
   their own design docs and cite it.
4. **The room accents, in both themes, are defaults in the shared header
   package,** because every header shows all of them. The other family
   values reach the apps as the shared header's custom properties, set in
   each app ([ADR-014](014-shared-ui-packages.md)), not as a separate token
   package. `DESIGN.md` stays the one source, and its check in `khe-sites`
   compares the package's copy with it.
5. **A room that does not meet the rule yet says so in its `AGENTS.md`**,
   where an agent working there will read it. A room that keeps its own
   look for good says so the same way and cites its exception (ADR-025,
   ADR-028).
6. **The header names the room in a rooms menu.** The mark always leads to
   the khe.ee front page. Every page but the khe.ee landing shows a button
   with the current room's name; it opens a list of every room, each with
   its dot, its name and a short note, the current room marked. Inside an
   app the app's name follows the room after a slash. A page's own name
   lives in its heading, not in the header. The landing shows only the
   mark. A product page shows this in its frame view only (ADR-030 point
   2), and the stories family build's own header has no menu (ADR-032).
7. **The room list lives in the shared package and counts as
   presentation.** The names, notes and public addresses are in
   [`khe-ui`](https://github.com/khelias/khe-ui), so every room lists the
   same rooms. Under ADR-014 point 2, as
   [ADR-017](017-shared-theme-toggle-and-footer.md) point 1 did for the
   theme, the list is the family's navigation chrome, not app state.
8. **`@khelias/ui` carries a design check of presentation rules,** which
   counts as presentation under ADR-014 point 2. Every web app runs it in
   its lint, so its own check and CI fail on a new violation. It counts
   gradients, blur, shadows, large radii, default palette colours,
   capitals, wide tracking, emoji and em dashes in strings per file
   against a baseline the repo commits, and the baseline only shrinks: a
   count above it fails, a count below it asks for the baseline to be
   rewritten, and raising it fails unless the check's version changed. A
   line may opt out with a comment that names the rule and gives a
   reason. The stories room's content and the family build's header and
   footer are outside it (ADR-028 point 1, ADR-032 point 1).

## Alternatives considered

- **A header label for partly replaced ADRs:** a format change in the
  check and the page that renders the ADRs, and the reader would still
  assemble the rule from several ADRs.
- **Leaving ADR-021 with annotated Related links:** the status says
  Accepted for points that no longer hold as written.

## Consequences

- Adding, renaming or moving a room is a `khe-ui` release plus each app's
  bump; an app that has not merged it lists the old rooms.
- A change to a room accent is a `DESIGN.md` edit, a `khe-ui` release for
  the dots, and one value change per app for the `.ee`.
- A change to the check's rules is a `khe-ui` release plus each app's
  bump, and the new version may raise a baseline.
- The check reads source, not rendering: a centred hero, three icon
  cards or invented numbers stay a matter for review.
- `khe-home-assistant` has no npm project and is outside the check; its
  3D view and the `/ha/` header follow point 1 by review, its dashboard
  is excepted (ADR-025).
- A page without the Popover API shows the mark and no menu; the mark
  still leads to the front page.
- Revisit when a room needs its own links in the menu, when the rooms
  outgrow one short list, or when two rooms need the same state colours,
  which then become shared tokens.
