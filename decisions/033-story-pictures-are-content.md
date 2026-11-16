# ADR-033: Story pictures are content, shipped as checked SVG files

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (the content contract between the app and the stories), [ADR-029](029-family-stories-are-published-with-the-childrens-names.md), [ADR-032](032-unejanku-owns-its-header-and-footer.md)

## Context

Unejänku draws a small picture on every story card and in the player. The
app in [khe-stories](https://github.com/khelias/khe-stories) owns a handful
of drawings, and a story in
[khe-bunny-tales](https://github.com/khelias/khe-bunny-tales) only picks
one by key, so most stories share the same moon. A picture made for each
story, a night scene with its own characters drawn from its own text,
belongs with the story: it changes when the story is told, it can show
who is in it, and like the text it must not reach the public repo.

An SVG file is a document, not only an image. Served from the app's own
origin it opens as a page there, so a script, an event handler, an
external reference or an entity in it would run or load with that origin's
rights. Drawn through `<img>` it runs no script, but the file itself is
still served.

## Decision

1. **A story's picture is an SVG file in the content repo**, named by the
   story and shipped through the content contract of ADR-031 beside the
   story's text. The catalog names the file; a story without one draws the
   app's fallback scene, which the app keeps.
2. **How a picture is made is the content repo's concern.** The app sees
   only the files; a generator, a drawing tool or a hand-made file are the
   same to it. The public repo holds pictures of its invented demo stories
   only.
3. **The app draws a picture with `<img>`**, never inline in the page, so
   no part of the file can reach the page's script or styles.
4. **The build rejects an unsafe or oversized file.** The contract fixes a
   size limit, one view box and an allowlist of elements and attributes,
   with local `url(#id)` references only: no scripts, event handlers,
   external or `href` references, entities, styles or animation. The app's
   build checks every picture it ships and fails on one that breaks it; the
   content repo checks the same rules first, so a bad file fails before the
   app build. The public build carries only the pictures of the stories it
   publishes, and its leak check covers them.

## Alternatives considered

- **Keep the drawings in the app, picked by key:** each new picture would
  be a release of the public app, and a picture of the family's own
  characters would sit in the public repo.
- **Raster images (PNG, WebP):** safe by nature, but a layered scene is a
  few tens of kilobytes as SVG and stays sharp on every screen, and a
  raster file per size and density costs more to ship offline.
- **Inline SVG in the page:** lets CSS reach into the drawing, but any
  script or handler a check missed would run in the app.
- **A sanitiser that rewrites the file:** a rewrite can change the
  picture without anyone seeing it; a check that fails the build keeps the
  file as it was drawn.

## Consequences

- A new story's picture is added with the story, with no change to the
  app.
- The allowlist limits what a picture can use; a drawing that needs more
  (a pattern, a mask, an image) is a contract change on both sides.
- The pictures are precached with the texts, so the offline build grows
  by a few tens of kilobytes per story.
