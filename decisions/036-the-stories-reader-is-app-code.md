# ADR-036: The stories reader is app code

- **Status:** Accepted (2026-11-17)
- **Related:** [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (extends point 1 to the reader), [ADR-033](033-story-pictures-are-content.md) (point 2 is about pictures and stands)

## Context

Every story in Unejänku is read aloud by a computer voice: TartuNLP's XTTS
v2 Estonian in the voice of the children's dad, with each piece checked by
Whisper and by its pitch, the story cut into pieces with pauses between
them, and the result encoded as AAC. That code, the reader, lives in the
private [khe-bunny-tales](https://github.com/khelias/khe-bunny-tales),
beside the stories it reads, together with what was learnt about the
engine.

Nothing in the reader is private once its examples and two inputs are:
the Whisper prompt, which names the children so that Whisper spells them
right, and the spoken subtitle read after each title. The voice clips are
private and stay so. Kept private, the code and the method are seen by
nobody, and the next step for the stories, writing a new story from the app,
needs the reader to run on a server, from code the app's deploy can reach.

[ADR-031](031-stories-public-app-private-stories-audio-outside-git.md)
point 1 put the app's code in the public
[khe-stories](https://github.com/khelias/khe-stories) and the content in
the private repo, which builds the app at the commit its `app.ref` names.
It said nothing about the reader, which was then a script of the export.

## Decision

1. **The reader is app code and lives in khe-stories `reader/`**, with its
   method in `docs/reader.md` there. It takes a story's text, the voice
   clips, the subtitle and the Whisper prompt as inputs and holds no family
   content: no name, no clip, no story. khe-bunny-tales runs it from the
   checkout its `app.ref` names, so one pin names both the app and the
   reader a build or a reading used.
2. **A story's `voice` tag stays a khe-bunny-tales tag.** A tag pins a
   khe-bunny-tales commit, whose `app.ref` pins the reader, so every
   existing tag stays valid and the move re-reads nothing. An `app.ref`
   bump that changes `reader/` cuts a new tag; one that leaves `reader/`
   alone does not.

## Alternatives considered

- **Keep it private:** nobody sees how the voice was made, and the server
  reading of the next step would need the private repo on the server.
- **A separate public repo:** another pin, another CI and another set of
  dependency updates, for code that serves only this app.
- **A public copy beside the private one:** two copies drift, and nobody
  can tell which one read a story.

## Consequences

- A change to how a story is read is a khe-stories pull request, then an
  `app.ref` bump in khe-bunny-tales and, when `git diff <old>..<new> --
  reader/` is not empty, a new voice tag.
- Renovate leaves `reader/` alone: its pins decide how a story sounds, so
  they move by hand with a new tag.
- The reader is public for good, in khe-stories' history. A family name
  reaching it is a leak like any other in that repo, so its examples and
  tests use invented names and its family inputs are arguments.
- The reader's interface is a command line, run under `uv` with its own
  pinned packages, so the private repo's environment never imports it.
