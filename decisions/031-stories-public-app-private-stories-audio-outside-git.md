# ADR-031: Stories: public app code, private stories, audio outside git

- **Status:** Accepted (2026-11-21)
- **Supersedes:** [ADR-033](033-story-pictures-are-content.md), [ADR-036](036-the-stories-reader-is-app-code.md)
- **Related:** [ADR-001](001-repo-per-product.md) (deviates: a public app deployed by its private content repo), [ADR-016](016-static-fallback-at-the-edge.md) (deviates from points 1-2), [ADR-029](029-family-stories-are-published-with-the-childrens-names.md) (replaces point 4 for stories published from now on), [ADR-035](035-family-shell-and-design-check-with-its-exceptions.md) (the family build's own look), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (amends point 10, extends point 14), [ADR-041](041-installed-apps-stay-on-their-paths-with-a-worker-each.md) (extends point 8 to every installed app)

## Context

The bedtime stories were a room of the public khe-sites, each reading
committed there for good (ADR-029 point 4). They now get an app, Unejänku:
a family build and a public build with the stories the parents choose,
which resumes and plays offline. The code holds nothing private once the
stories, their pictures and the family's voice are out of it. A text is
small and git suits it; a reading is megabytes, git keeps every version,
and Git LFS turns off for the whole account on a quota overrun. The edge
copy ignores range requests, which Safari needs for audio. Publishing to
everyone ends the GDPR household exemption, so a story must be erasable. An
SVG served from the app's origin opens as a page there, so anything active
in it runs with that origin's rights.

## Decision

1. **Three homes.** The app's code lives in the public
   [khe-stories](https://github.com/khelias/khe-stories), with invented
   demo stories and CI on GitHub-hosted runners only. The family's stories
   stay in the private khe-bunny-tales. The audio lives outside git, on the
   homelab disk. khe-sites gives up the stories room.
2. **The private content repo owns the deploy**, building both builds from
   a pinned khe-stories commit. This deviates from ADR-001: the content
   never enters the public repo or its CI.
3. **Audio is a content-addressed file store, not a repo**, served by the
   homelab with range requests: the family build reaches all of it, the
   public build only the published readings. It is in the offsite backup,
   never served from there, so the hosting line of
   [ADR-014](014-shared-ui-packages.md) holds. Layout: khe-stories
   [`docs/content.md`](https://github.com/khelias/khe-stories/blob/main/docs/content.md).
4. **A story published from the move on can be withdrawn** everywhere,
   offline copies included, replacing ADR-029 point 4 for those stories.
5. **The edge copy holds the public build without its audio**, a deviation
   from ADR-016 points 1-2; in an outage the page shows the text.
6. **The family build sits behind Cloudflare Access at `stories.khe.ee`**,
   open from home as the trip atlas is, never in the edge copy, with the
   product view only and the room's own look (exceptions in ADR-035).
7. **The public build holds only published stories and checks its own
   output for leaks**: no unpublished story, no name the export refuses
   (ADR-029 point 3), no source maps. A story has one text.
8. **A service worker and offline storage, the estate's first.** Audio is
   stored only when the listener saves a story and otherwise never passes
   the worker; the worker is versioned, prunes withdrawn stories and has a
   kill-switch, as khe-stories
   [`AGENTS.md`](https://github.com/khelias/khe-stories/blob/main/AGENTS.md)
   says.
9. **The AI voice is disclosed** on every build (AI Act Art. 50).
10. **A story's picture is an SVG file in the content repo**, shipped
    through the content contract beside its text; without one the app draws
    its fallback scene.
11. **How a picture is made is the content repo's concern.** The public
    repo holds its demo stories' pictures only.
12. **The app draws a picture as an image, never inline**, so the file
    cannot reach the page's script or styles.
13. **The build rejects an unsafe or oversized picture** against the
    contract's allowlist, which the content repo checks first; the public
    build carries only its stories' pictures.
14. **The reader is app code in khe-stories** with no family content: the
    voice clips and the names are its inputs. The content repo runs it from
    the pinned app commit, so one pin names the app and the reader.
15. **A story's voice tag stays a content-repo tag**; a pin bump that
    changes the reader cuts a new one.

## Alternatives considered

- **Stay in khe-sites:** readings public for good, and no family build.
- **The app in the private repo:** simplest deploy, but its code could not
  be read as a reference (ADR-001).
- **R2 or LFS as the primary store:** the stories with a third party, or
  every version kept under an account-wide quota.
- **Inline SVG or a rewriting sanitiser:** a missed script would run, and a
  rewrite changes a picture unseen.
- **The reader private or in its own repo:** a server reading would need
  the private repo; a separate repo is one more pin and CI.

## Consequences

- A build needs both repos, and a pin bump is a deliberate commit; a
  reading change is a khe-stories pull request, a bump and a voice tag.
- Losing the disk and the offsite copy loses readings that can be made
  again, not restored.
- A withdrawn story stays on a device until it next opens the app online.
- A picture that needs more than the allowlist is a contract change on both
  sides. The reader is public for good, so family names are only arguments.
