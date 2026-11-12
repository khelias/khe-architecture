# ADR-025: The house dashboard keeps its own look

- **Status:** Accepted (2026-11-12)
- **Related:** [ADR-021](021-family-shell-and-design-check.md), [ADR-014](014-shared-ui-packages.md)

## Context

[ADR-021](021-family-shell-and-design-check.md) point 1 puts every room's
shell under the family values: the ground, the type, the surfaces, the
controls and the dialogs around a room's content. Play areas, canvases,
maps and the house drawing keep their own look. Its Consequences add that
`khe-home-assistant` has no npm project and is outside the design check,
so its dashboard and 3D view follow point 1 by review.

Home Assistant's dashboard is the household's daily tool for the house:
the price, the heating, the ventilation, the pergola and the alarm, on a
phone, many times a day. Two redesign rounds under point 1 did not land.
The first drew the dashboard with the repo's own cards in the family's ink
and paper and was rejected for hiding one-tap actions; the second used a
community card set without blur, translucency or a background, as point 1
asks, and was judged no prettier than the stock dashboard. What the rule
took out, glass surfaces over a soft background, is what the household
reads as a beautiful house dashboard. A third design that keeps every
one-tap action and puts glass cards over a soft gradient, with the 3D
house on top, was approved on 2026-11-12.

The dashboard is reached from Home Assistant's own sidebar and app, never
from a khe.ee page, and no khe.ee header surrounds it. Only the public demo
at `khe.ee/ha` puts it inside the family shell, and the demo does not show
the new design.

## Decision

1. **Home Assistant's dashboard is an application inside the House room,
   like the house drawing.** It keeps its own look and may use glass,
   blur, translucency, gradients, a view background and its own controls.
   ADR-021 point 1 does not apply to it, and the review that ADR-021's
   Consequences name does not hold it to the family values.
2. **The family shell around the house still follows ADR-021.** The khe.ee
   pages and the `/ha/` demo's header keep the family's ground, type and
   controls; the House room's accent stays the family's.
3. **The house's look stays in its repo.** `khe-home-assistant` records
   its dashboard decisions in its own ADRs and states this exception in its
   `AGENTS.md`, as ADR-021 point 5 asks of a room that does not meet the
   rule.

## Alternatives considered

- **Keep point 1 and design within it:** two rounds did this and neither
  was used; a third would repeat the constraint that made them plain.
- **A repo ADR in `khe-home-assistant` alone:** ADR-021 names the
  dashboard in its Consequences, so a repo decision cannot lift an estate
  one.
- **An exception under ADR-021 point 5 only:** point 5 is for a room that
  does not meet the rule yet, with the rule as the goal. Here the goal
  itself is different.

## Consequences

- The house dashboard and the family can drift apart in look; a khe.ee
  page that shows the dashboard (a screenshot, the demo) shows it as room
  content, not as shell.
- Glass and blur cost rendering time on older phones; the dashboard
  honours reduced transparency and reduced motion settings.
- If the dashboard is ever served under a khe.ee page with the family
  header, the shell around it follows ADR-021 again; this ADR covers the
  dashboard's content only.
