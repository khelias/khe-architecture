# ADR-031: Stories: public app code, private stories, audio outside git

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-001](001-repo-per-product.md) (deviates: a public app deployed by its private content repo), [ADR-013](013-trips-public-demo.md), [ADR-016](016-static-fallback-at-the-edge.md) (deviates from points 1-2), [ADR-017](017-shared-theme-toggle-and-footer.md), [ADR-028](028-the-stories-room-keeps-its-own-look.md) (replaces point 3), [ADR-029](029-family-stories-are-published-with-the-childrens-names.md) (replaces point 4 for stories published from now on), [ADR-030](030-the-portfolio-frame-and-the-product-view.md) (deviates from point 2 on stories.khe.ee), [ADR-022](022-home-route-for-access-only-apps.md), [ADR-032](032-unejanku-owns-its-header-and-footer.md) (the family build's own header and footer, point 6), [ADR-033](033-story-pictures-are-content.md) (story pictures join the content contract)

## Context

The bedtime stories are published at `khe.ee/stories/` from
[khe-sites](https://github.com/khelias/khe-sites), a public repository:
each story's text and its m4a reading are committed there, so a published
story stays in that history for good
([ADR-029](029-family-stories-are-published-with-the-childrens-names.md)
point 4). The stories now get an app of their own, Unejänku, the name from
[ADR-030](030-the-portfolio-frame-and-the-product-view.md): a family build
for both parents at `stories.khe.ee` and a public build at
`khe.ee/stories/` with the stories the parents choose. Beyond today's page
it resumes where listening stopped and plays offline; later it makes a new
story itself.

That leaves three things to place: the code, the stories and the audio.
The code holds nothing private once the stories are not in it. A story's
text is a few kilobytes with one writer, the agent session, and git gives
it history, review and the name guard for free. A reading is megabytes,
changes when a story is read again, and git keeps every version; the two
stories in khe-sites already weigh 16 MiB there. Git LFS on GitHub turns
LFS off for the whole account when a quota is overrun. The edge copy of
[ADR-016](016-static-fallback-at-the-edge.md) is served by Workers Static
Assets, which ignore `Range`
([workers-sdk #8967](https://github.com/cloudflare/workers-sdk/issues/8967),
closed as not planned), and Safari does not play audio without it.

Publishing to everyone ends the GDPR household exemption, so the public
build needs a way to erase a story, which ADR-029 point 4 ruled out. The
AI Act's Art. 50 transparency duty for synthetic voice is in force since
2026-08-02.

## Decision

1. **Three homes.** The app's code lives in the public
   [khe-stories](https://github.com/khelias/khe-stories), with a few
   invented demo stories as fixtures and CI on GitHub-hosted runners only.
   The family's stories (text, front matter, timings) stay in the private
   [khe-bunny-tales](https://github.com/khelias/khe-bunny-tales). The
   audio lives outside git, on the homelab disk. khe-sites gives up the
   stories room; this replaces ADR-028 point 3.
2. **The private content repo owns the deploy.** khe-bunny-tales checks
   out khe-stories at a pinned commit, builds both builds with its own
   content and copies them to the homelab. This deviates from
   [ADR-001](001-repo-per-product.md), where a product deploys from its
   own repo: the content never enters the public repo or its CI.
3. **Audio is a content-addressed file store, not a repo.** Each reading
   is stored once under its SHA-256, the catalog in khe-bunny-tales
   records the hash and duration, and the homelab's nginx serves the store
   with `Range`. The family build reaches all of it, the public build only
   the published hashes, which the deploy places beside it. The store is
   in the existing restic offsite backup to Cloudflare R2 in the EU
   jurisdiction. R2 is a backup, never the origin, so
   [ADR-017](017-shared-theme-toggle-and-footer.md) point 5 holds. A lost
   reading can be made again from its text and voice, not bit for bit.
4. **A story published from the move on can be withdrawn.** It leaves the
   origin at the next deploy, the edge copy at the next sync and a
   visitor's offline copy at their next visit online. This replaces
   ADR-029 point 4 for those stories; the two already in khe-sites'
   history stay public for good.
5. **The edge copy holds the public build without its audio**, a
   deviation from ADR-016 points 1-2: the copy no longer mirrors all the
   homelab serves. During an outage the page shows the text and says the
   reading is not available right now.
6. **The family build sits behind Cloudflare Access at `stories.khe.ee`**
   (the home network and Tailscale without sign-in, as trips), is never in
   the edge copy, and shows the product view only. That is a deviation
   from ADR-030 point 2: the host has no frame page. ADR-028 point 1, the
   room's own look, extends to it.
7. **The public build holds only stories marked published and checks its
   own output for leaks**, the rule of
   [ADR-013](013-trips-public-demo.md): no unpublished story's title,
   route, text or audio, no name the export refuses (ADR-029 point 3), no
   source maps. A story has one text; there is no renamed public version.
8. **A service worker and offline storage, the estate's first,** scoped to
   the app on both hosts. Audio is stored only when the listener saves a
   story, as the full response in Cache Storage, and played back through
   range slicing, never through `blob:` URLs, which have regressed on iOS.
   Unsaved audio never passes the worker. The worker is versioned, prunes
   withdrawn stories when it activates, and has a kill-switch.
9. **The AI voice is disclosed** in one line on every build (AI Act
   Art. 50).

## Alternatives considered

- **Stay in khe-sites:** every reading in a public history for good, no
  withdrawal, and no place for the family build.
- **The app in the private khe-bunny-tales:** the simplest deploy, but
  the code holds nothing private and could not be read or cloned as a
  reference project (ADR-001).
- **Cloudflare D1 and R2 as the primary store:** the stories would rest
  with a third party and be served from the edge, and the hosting line of
  ADR-017 point 5 would stop being true.
- **Git LFS:** a quota overrun turns LFS off for the whole account, and
  every version is still kept.
- **A database now:** one more service to run and back up while the agent
  session is the only writer. It comes with the second writer, a story
  made from the app.
- **No offline:** listening away from a network is one of the reasons for
  the app; without it the app adds little over today's page.

## Consequences

- khe-stories can be read and cloned on its own, with demo stories in
  place of the family's.
- A build needs both repos; moving the pinned app commit in
  khe-bunny-tales is a deliberate commit.
- From the move on no reading is in any git history. Losing both the
  homelab disk and the offsite copy loses readings that can be made again
  but not restored.
- During an outage visitors outside the home network get the text without
  the reading.
- A withdrawn story stays on a visitor's device until they next open the
  app online.
- A new story made from the app, with its database and writers, gets its
  own ADR. khe-trips can follow this pattern if it is made public.
