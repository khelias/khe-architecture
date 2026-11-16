# ADR-034: The demo line links the real site

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-014](014-shared-ui-packages.md), [ADR-030](030-the-portfolio-frame-and-the-product-view.md) (replaces point 4)

## Context

The family reaches the house, the trips and the stories through khe.ee,
because that is the address they remember. From there they land on the
demos: `khe.ee/ha/`, `khe.ee/trips/` and `khe.ee/stories/`. The demo
line under the header
([ADR-030](030-the-portfolio-frame-and-the-product-view.md) point 4) says
what the demo shows and what stays private, and then stops: it gives the
family no way on to the real site.

The real sites differ in how they are reached. `home.khe.ee` answers on the
home network and over Tailscale only. `trips.khe.ee` and `stories.khe.ee`
sit behind Cloudflare Access outside the home network,
and both read a
`?lang` parameter for the page's language.

## Decision

1. **A demo whose real site the family reaches carries one link to it**,
   after the demo line's sentence and labelled for the family: "Perele →"
   in Estonian, "For family →" in English, the same words on every demo.
2. **The `href` is the real site's root**, with the page's language as
   `?lang` where the site reads it, and without it where the site has its
   own (Home Assistant).
3. **The link is an optional part of the package's demo line**, not markup
   each app adds: the line belongs to `@khelias/ui`
   ([ADR-014](014-shared-ui-packages.md), ADR-030 point 4), so the
   [`khe-ui`](https://github.com/khelias/khe-ui) header takes it as an
   option and the apps pass the address and the words.
4. **A stranger who follows the link meets the sign-in page**, or for the
   home site a name that does not resolve. The label says the link is for
   the family, and that dead end is accepted.

This replaces ADR-030 point 4; its other points stand.

## Alternatives considered

- **No link:** the family has no way on from the demo they land on.
- **A family entry on the landing:** a second door for the same thing; the
  demo line is where the family already is.
- **A word of the sentence as the link:** unclear that it leaves the demo.

## Consequences

- The demo line can run to two lines on a narrow screen. An app that
  positions content under the header measures the line instead of assuming
  one line's height.
- The three addresses are public in the demos' markup. They were already
  named in the estate's public docs, and each one is guarded by its own
  network or sign-in.
- The family reaches the house at home or over Tailscale and the trips and
  stories through Access; a family member the Access policy does not admit
  still meets its sign-in page.
