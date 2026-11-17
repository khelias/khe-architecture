# ADR-037: The children's stories are made by an unattended job from a request the app sends

- **Status:** Proposed (2026-11-17)
- **Related:** [ADR-004](004-app-backend-and-identity.md) (points 2, 5 and 6 do not apply to these stories), [ADR-027](027-attended-and-unattended-agent-tiers.md) (points 4-6 are the job's boundary), [ADR-033](033-story-pictures-are-content.md) (amends point 1), [ADR-036](036-the-stories-reader-is-app-code.md) (the reader also runs on Linux), [ADR-038](038-a-childs-device-is-paired-once-by-a-parent.md) (how a child's phone may send a request)

## Context

The children want to make their own bedtime stories in Unejänku, on their
own phones, and hear them read in their dad's voice, as the family's
stories are. Either a child writes the text herself and it is only tidied
up, or she picks who is in it, where and what kind, says or types her idea,
and a model writes it. Waiting is fine if it happens in the background and
a notification says when the story is ready.

What a story needs is already in place, but in three places. The text is
written by Claude, which we pay for by subscription, not per call. The
reader (ADR-036) takes minutes per story on a laptop and needs the dad's
voice clips, which live in the private content repo. The audio store and
the deploy of the family build sit in the homelab, which a GitHub-hosted
runner cannot reach; the content repo's deploy job on the homelab runner
is the only bridge. A story appears in the app only after a deploy,
because the catalog is bundled at build time.

ADR-027 points 4-6 already describe an unattended job on the subscription
token: a model job that holds no write token, a model-free job that makes
the write, pinned actions, timeouts, a turn limit and one run at a time.

## Decision

1. **A paired phone sends a request to a small service in the homelab.**
   The service queues it and dispatches one run of a content-repo workflow
   at a time.
2. **The run follows ADR-027 points 4-6.** A model job with a read-only
   token writes the story file. Jobs without a model take only that file,
   review it with a second model (Gemini), draw its picture and read it
   with the reader on the GitHub-hosted runner. A homelab-runner job puts
   the audio in the store. A model-free job checks the result and commits
   the story's own files to the content repo's `main`. The deploy then
   publishes it to the family build and tells the service, which sends the
   notification.
3. **No parent approves a story before the children hear it.** The checks
   are the second model's review, the content repo's own checks, the
   personal-data scan and the reader's Whisper check. A story is withdrawn
   by deleting its file. A child's story reaches the public build only by
   the line in its front matter that publishes any story.
4. **It is a content writer, not the builder of ADR-027 point 7.** It
   pushes story files, never code, so ADR-023 stands for it and this ADR is
   its envelope in the writer register (ADR-007).
5. **ADR-004 points 2, 5 and 6 do not apply.** Those cover app data behind
   an API. These stories are git content with git's history, and the
   child's request is the acceptance. The service's queue, paired devices
   and push subscriptions are not app data: losing them means pairing and
   asking for notifications again, and no story is in them.
6. **A child's story may have a raster picture.** This amends ADR-033
   point 1 for the children's shelf only. Point 4's checks keep applying,
   with raster rules (format, exact size, a byte limit) beside the SVG
   ones, and the picture is still drawn with `<img>`.
7. **The reader also runs on Linux x86 CPU**, extending ADR-036. The
   macOS reading of existing stories does not change.

## Alternatives considered

- **A live API with keys, as the adventure game's proxy does:** billed per
  call, and the reading takes minutes anyway, so nothing is gained by
  answering live.
- **Reading on docker-vm:** more cores and faster, but the load lands on
  the house's services and a model-adjacent job runs in the homelab,
  which ADR-027 keeps out.
- **A parent approving each story first:** the child waits for a parent,
  which is the waiting she did not want.

## Consequences

- The private repo's free Actions minutes pay for the readings as well as
  its builds, so the service caps stories per month.
- A bad story is on the children's shelf until we delete it; the review
  and the checks are the only gate before it.
- The subscription token sits in a GitHub environment limited to `main`,
  as ADR-027 point 5 accepts.
- The homelab gains a small backend whose state is disposable, with its
  own image built in CI and pinned by digest (ADR-008).
