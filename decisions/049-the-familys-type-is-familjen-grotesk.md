# ADR-049: The family's type is Familjen Grotesk

- **Status:** Accepted (2026-11-20)
- **Related:** [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md) (the shell this type is part of; `DESIGN.md` holds its values by point 3), [ADR-028](028-the-stories-room-keeps-its-own-look.md) (the stories room's content keeps its own type)

## Context

Every room's shell used two typefaces: Source Serif 4 for the name,
titles and headings, and Inter for everything else. A friend shown
khe.ee said at once that it was made with AI. A serif display over
Inter is the look of the AI assistants' own sites and the type the
brands around them reach for, so the pair reads as generated before a
visitor reads a word.

The type spans every web app in the estate: the khe.ee and games.khe.ee
pages, the workshop room, the shared header's defaults, the study games,
the adventure game's shell, the public stories build and the trips
atlas. Each self-hosts its font files, and the khe.ee share images and
favicon carry the text as paths, so a change is costly to reverse.

## Decision

1. **The family's one typeface is Familjen Grotesk** (SIL Open Font
   License 1.1, variable weight 400 to 700, latin and latin-ext subsets),
   for the name, titles, headings, body text and controls of every
   room's shell. The stack is `'Familjen Grotesk', system-ui,
   sans-serif`; facts keep the system monospace stack.
2. **Each app self-hosts the two subset files** with the licence text,
   from the Fontsource build of Google Fonts' release. No app loads the
   font from a third-party host.
3. **The weights and tracking are in the family `DESIGN.md`**
   (ADR-035 point 3), not here.
4. **Play areas keep their own type** under ADR-035 point 1: the
   adventure game's stage keeps its serif, and the trips atlas (hero,
   day titles, prices) keeps its system serif. Their shells move.
5. **The stories room keeps its type.** Its content (ADR-028 point 1) and
   the family build's own header and footer
   ([ADR-032](032-unejanku-owns-its-header-and-footer.md)) are outside
   the shell; only the public build's family header and footer move.

## Alternatives considered

- **Keep the serif and sans pair:** it is the look that reads as
  generated, the reason for this decision.
- **The system font in place of Inter, kept with the serif:** tried on
  2026-11-17. On Apple devices the system font is close enough to Inter
  that nothing visible changed, and the serif stayed.
- **Schibsted Grotesk or Hanken Grotesk:** rendered beside Familjen on
  the landing at desktop and phone width on 2026-11-20; we chose
  Familjen from those renders.
- **The ADR-028 direction (system type with a reading serif) for the
  whole family:** it suits reading a story, not the rooms' shells, and
  the system type is the same that changed nothing in the 2026-11-17
  trial.

## Consequences

- khe.ee ships one variable font in two subset files in place of four
  Inter weights and two serif files.
- Each app that self-hosts fonts carries the two Familjen files and the
  licence; a page that misses them falls back to the system font.
- The share images and the favicon are redrawn as paths from Familjen.
- `khe-ui`'s header and footer default to the new stack; the apps set the
  header and footer font properties themselves, so none waits for its
  release.
- Undo is a revert in each repo and a superseding ADR.
