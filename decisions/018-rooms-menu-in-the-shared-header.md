# ADR-018: The shared header names the room in a rooms menu, and the package carries the room accents

- **Status:** Superseded (2026-10-23)
- **Superseded by:** [ADR-021](021-family-shell-and-design-check.md)
- **Supersedes:** [ADR-015](015-family-design-layer.md)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-017](017-shared-theme-toggle-and-footer.md)

## Context

[ADR-015](015-family-design-layer.md) made the KHE sites one family of
rooms: Home, Games, House, Trips and Server, each with one accent shown
only in the `.ee` of the KHE.ee mark. The shared header still says where
you are in three different ways: a kicker over a title ("KHE Games"), a
page title ("Architecture", "Privacy") or nothing, and the words repeat
the page heading under them. Nothing in the header says that the other
rooms exist, and the mark leads to the front page of whichever site you
are on, not to khe.ee.

We drew five header variants side by side and chose a rooms menu: the
mark, then the current room's name with a chevron that opens a list of
every room. The list shows each room's accent as a dot, which ADR-015
point 1 rules out, and every header then shows all five accents, which
ADR-015 point 4 left to each app. ADR-015 is Accepted, so this ADR replaces
it and restates the points that stand.

## Decision

1. **Every site or app is a room with one accent.** The shared chrome (the
   header, the mark, the language switcher, the page ground and the type of
   the page chrome) uses the family ground, ink and type in every room. The
   room's accent appears in the chrome in the `.ee` of the mark and as each
   room's dot in the rooms list; nothing else in the header is coloured.
   Room content that is an application (a game, the Home Assistant
   dashboard, the trip atlas) keeps its own visual language and ground.
   State colour (on and off, ok, warning, fault, a map state, right or
   wrong) is meaning, not an accent, and a room may use several.
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
4. **The five room accents, in both themes, are defaults in the shared
   header package,** because every header now shows all five. The other
   family values reach the apps as the shared header's custom properties,
   set in each app ([ADR-014](014-shared-ui-packages.md)), not as a
   separate token package. `DESIGN.md` stays the one source, and its check
   in `khe-sites` compares the package's copy with it.
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

## Alternatives considered

- **A trail of links** (`khe.ee › Games › the game`): three links where
  one does, and it still lists no other room.
- **An arrow back to the parent:** says where you came from, not where
  else you can go.
- **The address in the mark** (`games.khe.ee`): readable only to people
  who read addresses, and the mark stops being one mark.
- **An eyebrow over the page heading:** moves the room into each page's
  content, so every room draws it again.
- **The list per app:** each app keeps its own copy, which drifts as the
  headers did before ADR-014.
- **A link to the landing instead of a menu:** one more page between any
  two rooms, and the landing becomes a second room list to keep current.
- **Keep the accents in each app (ADR-015 point 4):** every app would set
  all five accents in both themes only to draw the dots.

## Consequences

- Adding, renaming or moving a room is a `khe-ui` release plus each app's
  bump; an app that has not merged it lists the old rooms.
- A change to a room accent is a `DESIGN.md` edit, a `khe-ui` release for
  the dots, and one value change per app for the `.ee`.
- A page without the Popover API shows the mark and no menu; the mark
  still leads to the front page.
- A room that commits to one theme or lags behind is visible in its
  `AGENTS.md`, not discovered by a visitor.
- Revisit when a room needs its own links in the menu, when the rooms
  outgrow one short list, or when two rooms need the same state colours,
  which then become shared tokens.
