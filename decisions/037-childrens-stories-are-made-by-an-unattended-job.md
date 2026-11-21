# ADR-037: The children's stories are made by an unattended job from a request the app sends

- **Status:** Proposed (2026-11-21)
- **Related:** [ADR-004](004-app-backend-and-identity.md) (points 2, 5 and 6 do not apply to these stories), [ADR-027](027-attended-and-unattended-agent-tiers.md) (points 4-6 are the job's boundary), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (amends point 10, extends point 14), [ADR-038](038-a-childs-device-is-paired-once-by-a-parent.md) (how a child's phone may send a request)

## Context

The children want to make their own bedtime stories in Unejänku, on their
own phones, and hear them read in their dad's voice, as the family's
stories are: either a child's own text, only tidied up, or a story a model
writes from who, where and what kind she picks and the idea she says or
types. Waiting is fine if it happens in the background and a notification
says when the story is ready.

What a story needs is in three places. The text is written by Claude on the
subscription, not per call. The reader (ADR-031 point 14) takes minutes per
story and needs the dad's voice clips, which live in the private content
repo. The audio store and the family build's deploy sit in the homelab,
which a GitHub-hosted runner cannot reach; the content repo's deploy job on
the homelab runner is the only bridge. A story appears in the app only
after a deploy, because the catalog is bundled at build time. ADR-027
points 4-6 already describe an unattended job on the subscription.

## Decision

1. **A paired phone sends a request to a small service in the homelab.**
   The service queues it and dispatches one run of a content-repo workflow
   at a time, from a request's text to its reading.
2. **The run follows ADR-027 points 4-6.** A model job with a read-only
   token writes the story file. Jobs without a model take only that file,
   review it with a second model, draw its picture and read it on the
   GitHub-hosted runner; a homelab-runner job puts the audio in the store.
   Model-free jobs commit twice to the content repo's `main`, each deployed
   to the family build: the text right after the review, then the reading
   and the picture, only while the story on `main` is still the run's text.
   The service reads the deployed catalog and tells the child once for the
   text and once for the reading; a reading that does not come leaves the
   text on the shelf and tells nobody. The states and timings are in the
   content repo's `AGENTS.md` "Deploy".
3. **No parent approves a story before the children hear it.** The second
   model's review, the content repo's own checks and the personal-data scan
   gate the text; the reader's Whisper check gates only the reading. A
   story is withdrawn by deleting its file. A child's story reaches the
   public build only as any story does, by being marked published.
4. **It is a content writer, not the builder of ADR-027 point 7.** It
   pushes story files, never code, so ADR-023 stands for it and this ADR is
   its envelope in the writer register (ADR-007).
5. **ADR-004 points 2, 5 and 6 do not apply.** Those cover app data behind
   an API. These stories are git content with git's history, and the
   child's request is the acceptance. The service's queue, paired devices
   and push subscriptions hold no story, and losing them means pairing and
   asking for notifications again.
6. **A child's story may have a raster picture.** This amends ADR-031
   point 10 for the children's shelf only; point 13's checks apply, with
   raster rules beside the SVG ones, and it is still drawn as an image.
7. **The reader also runs on Linux x86 CPU**, extending ADR-031 point 14.
   The macOS reading of existing stories does not change.

## Alternatives considered

- **A live API with keys, as the adventure game's proxy does:** billed per
  call, and the reading takes minutes anyway, so nothing is gained by
  answering live.
- **Reading on docker-vm:** faster, but the load lands on the house's
  services and a model-adjacent job runs in the homelab, which ADR-027
  keeps out.
- **A parent approving each story first:** the child waits for a parent,
  which is the waiting she did not want.

## Consequences

- The reading is the job's cost: about half an hour of the private repos'
  free Actions minutes per story, so the service caps the children's
  stories a month.
- A bad story is on the children's shelf until we delete it; the review
  and the checks are the only gate before it.
- The subscription token and the Gemini key are repository secrets, not
  the environment limited to `main` that ADR-027 point 5 names: GitHub
  Free has no environment secrets in a private repository. Only a workflow
  someone with write access pushes can read them, which is us alone, and
  every job of the chain runs from `main` only.
- The homelab gains a small backend whose state is disposable, with its
  own image built in CI and pinned by digest (ADR-008).
