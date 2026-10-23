# ADR-021: The family covers the application shell, and a design check in the shared package enforces it

- **Status:** Accepted (2026-10-23)
- **Supersedes:** [ADR-018](018-rooms-menu-in-the-shared-header.md)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-017](017-shared-theme-toggle-and-footer.md)

## Context

[ADR-018](018-rooms-menu-in-the-shared-header.md) made the shared chrome
(the header, the mark, the switcher, the page ground, the footer) one
family and let application content keep its own visual language. The
chrome reads as one family; the rooms behind it still read as generated.
The shell of the study room, the part around its games, carries dozens of
gradients and shadows, large radii, default violet and indigo classes,
emoji and capitals in its menus and notifications; the adventure stage
and the trip atlas carry the same habits in smaller numbers. They come
from application content, which ADR-018 point 1 leaves alone.

The family itself carried two of these signs: four of its room accents
were default palette values, and its labels were small mono capitals with
wide tracking and a dot. Those are a `DESIGN.md` change and a package
release, not a decision.

Nothing checks any of it. A rule in a document is skipped by the next
agent that does not read it, and only one style section in one repo has a
mechanical check. ADR-018 is Accepted, so this ADR replaces it, restates
its points 2 to 7 at their numbers (other documents cite them), rewrites
point 1 and adds the check as point 8.

## Decision

1. **Every room's shell uses the family values and rules.** The shell is
   the page ground, the type, the surfaces, the controls, dialogs,
   notifications, menus and lists around a room's content, as well as the
   shared chrome. Each room has one accent, shown in the chrome in the
   `.ee` of the mark and as each room's dot in the rooms list. Play areas,
   canvases, maps and the house drawing keep their own look, within the
   check's ratchet (point 8). State colour (on and off, ok, warning,
   fault, a map state, right or wrong) is meaning, not an accent, and a
   room may use several.
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
   where an agent working there will read it.
6. **The header names the room in a rooms menu.** The mark always leads to
   the khe.ee front page. Every page but the khe.ee landing shows a button
   with the current room's name; it opens a list of every room, each with
   its dot, its name and a short note, the current room marked. Inside an
   app the app's name follows the room after a slash. A page's own name
   lives in its heading, not in the header. The landing shows only the
   mark.
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
   reason.

## Alternatives considered

- **A stricter `DESIGN.md` only:** agents skip documents; the habits it
  would forbid are the ones they reach for first.
- **A workspace script in the commit gate:** no CI runs it, and the repos
  stop being self-contained.
- **A separate `@khelias/design-lint` package:** a second trusted
  publisher to set up and a first version published by hand, for code that
  ships beside the header every app already pins.
- **Stylelint with a Tailwind plugin:** new dependencies in four repos,
  and no rule for emoji or dashes in strings.
- **Fix every room at once:** the play areas would be rebuilt for a rule
  about their surroundings; the ratchet stops them getting worse instead.

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
  dashboard and 3D view follow point 1 by review.
- A page without the Popover API shows the mark and no menu; the mark
  still leads to the front page.
- Revisit when a room needs its own links in the menu, when the rooms
  outgrow one short list, or when two rooms need the same state colours,
  which then become shared tokens.
