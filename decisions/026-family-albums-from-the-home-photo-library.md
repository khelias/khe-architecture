# ADR-026: Family albums are selected from the home photo library by a local tool and written as Apple Photos favourites

- **Status:** Accepted (2026-11-14)
- **Related:** [ADR-001](001-repo-per-product.md), [ADR-007](007-automated-writers.md)

## Context

The family's photo albums (one per trip, one per season, one per event) are
kept in Google Photos, which the family and the television read. Making them
by hand means picking a few hundred frames out of a much larger roll, and
that work has fallen behind.

The same photos live in three places: Google Photos, Apple Photos on the
family Mac (its iCloud library) and the self-hosted Immich server. A
favourite (a heart) syncs between all three; albums do not. Whoever makes
an album hearts exactly the frames that go into it, so the hearts in Immich
are a record of past choices that a tool can learn from and be measured
against.

Google's Photos Library API cannot add photos it did not upload to an
album, and the web app ignores synthetic clicks. A heart set in Apple
Photos through its scripting interface reaches Google Photos with no phone
in the loop.

## Decision

1. **A new private repo, `khe-albums`, owns family album selection.** It is
   its own product under [ADR-001](001-repo-per-product.md), not a part
   of the trips app or the homelab, and it runs on the family Mac. It is
   not deployed.
2. **It reads from Immich and writes only Apple Photos favourites.** It
   reads assets, metadata and previews through a read-only Immich key. Its
   only write is setting a heart in Apple Photos; it never writes to Immich
   or Google directly, never creates an album and never deletes.
3. **Review happens by removing hearts, before the album exists.** The
   person who keeps the albums looks at the hearted frames in Google
   Photos, removes the ones that do not belong, and then makes the album
   from the Favorites view.
4. **The writer Acts under [ADR-007](007-automated-writers.md).** Its
   envelope (hearts only, only the named period, only on an explicit apply
   flag, a cap per run, every write logged) and its fallback (an undo that
   reverts a logged write only while the asset still holds the logged
   state) are written in the repo's `AGENTS.md` and in the writer register.
5. **Family data stays out of git.** Caches, previews, snapshots and the
   write log live in the user's cache and state directories; the repo holds
   code, the selection rubric, album names and dates, synthetic test data
   and aggregate results.

## Alternatives considered

- **The Google Photos Library API:** it can only add to an album media
  items the same app uploaded, so it cannot place existing photos.
- **Driving the Google Photos web app:** clicking frames one at a time works
  but does not scale, and scripted clicks are ignored.
- **A feature of the trips app:** albums cover seasons and events as well as
  trips, and the trips app has no access to the photo library; it would
  gain a second concern and a family-data dependency.
- **Writing hearts in Immich:** no tested path carries a heart set in Immich
  out to Apple Photos or Google Photos, and Immich is the record the tool
  learns from.

## Consequences

- Hearts become two things at once: the review queue and, once kept, the
  ground truth for later measurement. Periods the tool has written to are
  never used to evaluate it.
- The tool depends on the family Mac and its Apple Photos library being
  signed in; without them it can select but not write.
- The write log is local and not backed up. If it is lost, undo is by hand.
- Moving the judge from local agent runs to an API changes one module, not
  this decision.
