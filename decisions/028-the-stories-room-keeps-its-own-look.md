# ADR-028: The stories room keeps its own look

- **Status:** Accepted (2026-11-15)
- **Related:** [ADR-021](021-family-shell-and-design-check.md), [ADR-025](025-the-house-dashboard-keeps-its-own-look.md)

## Context

[ADR-021](021-family-shell-and-design-check.md) point 1 puts every room's
shell under the family values: the ground, the type, the surfaces, the
controls and the lists around a room's content. Its point 8 counts blur,
large radii and the other effects it rules out in every web app's lint.

The family's bedtime stories get a room of their own on khe.ee, Jutud,
where one story is published with the children's names changed and can be
read and heard. The first page drawn for it followed the family values:
the family serif and sans, grey text and small labels. We read it as
generated, the same impression the family type and grey labels have given
before. What we want instead is an Apple-style look: system type, a
reading serif, large rounded cards and a material behind the player, as
with the house dashboard in
[ADR-025](025-the-house-dashboard-keeps-its-own-look.md).

Whether the rest of the family should follow is open. This room is the
pilot: it shows what the direction looks like on a khe.ee page before the
family's type is decided again.

## Decision

1. **The stories room's content keeps its own look.** The library, the
   reading view and the player under `khe.ee/stories/` may use system
   type, their own reading serif, large radii, translucent materials with
   blur and their own controls. ADR-021 point 1 does not apply to them,
   and the design check excludes the room's files.
2. **The family shell around it still follows ADR-021.** The shared
   header with its rooms menu, the footer and the room's accent stay the
   family's; the room's accent is chosen like every other room's.
3. **The room's look stays in `khe-sites`.** Its `DESIGN.md` and
   `AGENTS.md` state the exception and cite this ADR, as ADR-021 point 5
   asks of a room that does not meet the rule.

## Alternatives considered

- **Keep ADR-021 and design within it:** the first page did this and was
  read as the generated look the family is trying to leave.
- **Move the whole family to the new look now:** that changes every room
  and ADR-021's typeface at once, on the strength of one page nobody has
  used yet. A pilot room costs one exception.
- **Opt-out comments per line under ADR-021 point 8:** the look is the
  whole room, not a few lines, and the comments would restate this ADR in
  every file.

## Consequences

- The stories room and the other rooms can drift apart in look; the
  header keeps them one family.
- Blur costs rendering time on older phones; it is kept to the player, and
  the page honours reduced transparency and reduced motion settings.
- If the family adopts this direction later, a new ADR supersedes
  ADR-021's typeface, and this exception goes with it.
