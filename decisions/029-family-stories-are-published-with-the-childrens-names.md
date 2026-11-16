# ADR-029: Family stories are published with the children's names

- **Status:** Accepted (2026-11-16)
- **Related:** [ADR-012](012-estate-architecture-is-public.md), [ADR-016](016-static-fallback-at-the-edge.md), [ADR-028](028-the-stories-room-keeps-its-own-look.md), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (replaces point 4 for stories published from now on)

## Context

The family's bedtime stories live in the private
[khe-bunny-tales](https://github.com/khelias/khe-bunny-tales). The stories
room in [khe-sites](https://github.com/khelias/khe-sites) was built to show
one of them, read aloud, with the children's names changed. The children
asked to hear their own names, and on 2026-11-15 both parents agreed. The
same day a second story was chosen for the room: the first one ever told, a
real-life story of an ordinary summer day, which the children like most.

Publishing a story is hard to undo. khe-sites is a public repository, so a
story stays in its history after it leaves the page, and the edge fallback
keeps a copy of the site. The stories also describe the family's home life,
so what they may carry has to be settled before more of them are published.

## Decision

1. **The parents choose which stories are published.** A story goes to the
   stories room only when one of us asks for it; nothing publishes a story
   on its own.
2. **The children's first names stay in a published story.** That is the
   parents' consent of 2026-11-15, given at the children's wish.
3. **Nothing else that identifies the family is published.** The export in
   khe-bunny-tales refuses a story that still holds the parents' names;
   other real people, schools and the like are renamed or left out by hand
   before a story is chosen. The pets and the family's roles (mum, dad) stay.
4. **A published story is treated as permanent.** Taking it down removes it
   from the page, not from the public history or the edge copy, and the
   decision to publish is made on that basis.

## Alternatives considered

- **One story only, as built:** the children asked for more, and the room
  was laid out as a library from the start.
- **Changed names in every story:** the children did not like hearing
  other names, which was the reason for the consent.
- **Behind Cloudflare Access, family only:** keeps the stories private but
  makes them one more sign-in for the people who listen; the stories carry
  nothing that needs it once point 3 holds.

## Consequences

- Each new story is a deliberate, one-way choice the parents make per
  story, and the export's name guard is the mechanical check.
- The private repo stays the single source: the room holds only what the
  export writes.
- If the children later want their names gone, the page can drop the
  stories, and a new ADR records that the history cannot be cleaned.
