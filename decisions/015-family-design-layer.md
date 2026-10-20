# ADR-015: The KHE sites read as one family: shared chrome, one accent per room

- **Status:** Accepted (2026-10-17)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-012](012-estate-architecture-is-public.md), [ADR-013](013-trips-public-demo.md)

## Context

The estate has several public faces: the khe.ee landing and its privacy
page, the architecture page and its decision pages, the trips demo and
shared trips, the 3D house demo, the games hub with two games inside it,
and the private trip atlas. We call each of them a room: Home, Server,
Trips, House and Games.

khe.ee speaks to clients and employers and to family and friends equally.
We want every room to have a light and a dark theme that follows the
system setting, the KHE.ee mark to stay, and the change to be a clear
evolution rather than a redesign.

[ADR-014](014-shared-ui-packages.md) put the site header into a shared
package and assumed the apps keep their own palettes and read as one family
through shared anatomy. In practice they did not: the landing and the games
hub were dark only, the trip atlas light cream, the brand suffix a different
red in each, and the favicon carried a tint nothing else used. A visitor
moving between rooms saw four sites with the same header layout. ADR-014's
Decision, a pinned presentation package styled through custom properties,
stands; this ADR replaces only its premise about palettes for the shared
chrome.

## Decision

1. **Every site or app is a room with one accent.** The shared chrome (the
   header, the mark, the language switcher, the page ground and the type of
   the page chrome) uses the family ground, ink and type in every room.
   The room's accent appears in the chrome only in the `.ee` of the mark.
   Room content that is an application (a game, the Home Assistant
   dashboard, the trip atlas) keeps its own visual language and ground.
   State colour (on and off, ok, warning, fault, a map state, right or
   wrong) is meaning, not an accent, and a room may use several.
2. **Every room has a light and a dark theme following the system
   setting.** A room may commit its content to one theme when the subject
   asks for it, and its header then takes that theme. A room may offer its
   own control to override the system setting.
3. **[`khe-sites`](https://github.com/khelias/khe-sites) owns the family
   `DESIGN.md`**, the one source of the family values: tokens in both
   themes, the rooms and the rules. Other repos keep only their room in
   their own design docs and cite it.
4. **The values reach the apps as the shared header's custom properties,
   set in each app** (ADR-014), not as a separate token package.
5. **A room that does not meet the rule yet says so in its `AGENTS.md`**,
   where an agent working there will read it.

## Alternatives considered

- **One look for every app:** the same ground, accent and type inside the
  games, the dashboard and the atlas. Rejected: a party game, a house
  drawing and a map each need their own language, and forcing one look on
  them is a redesign, not an evolution.
- **Palettes per app joined only by the header anatomy:** the premise of
  ADR-014. Tried, and it did not read as one family.
- **A token package, or the family values as defaults in the shared header
  package now:** one more release to coordinate while the family values
  are still settling, and ADR-014's custom properties already carry them.
  Kept as the way forward once the values hold.

## Consequences

- A family change is a `DESIGN.md` edit in `khe-sites` plus one value
  change per app.
- Copies of the family values live in each app until the shared package
  carries them as defaults.
- A room that commits to one theme or lags behind is visible in its
  `AGENTS.md`, not discovered by a visitor.
- Revisit when a copy drifts from `DESIGN.md`, or when two rooms need the
  same state colours, which then become shared tokens.
