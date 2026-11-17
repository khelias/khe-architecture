# ADR-039: Family deal alerts are an unattended job that takes requests from a Telegram chat

- **Status:** Accepted (2026-11-17)
- **Related:** [ADR-001](001-repo-per-product.md) (the watch repo has no CI of its own), [ADR-007](007-automated-writers.md), [ADR-023](023-agent-pushes-where-its-session-allows.md) (stands), [ADR-027](027-attended-and-unattended-agent-tiers.md) (points 4-6 are the job's boundary; point 5's egress note and point 3's host list change), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (the same kind of content writer)

## Context

We want to hear about second-hand listings that fit a search before
someone else buys them: first desktop DDR5 memory for the homelab host,
which at the current shortage is cheaper inside a used PC than on its own,
then the family's other searches. Alert apps for this exist, but none
reads the Estonian Hinnavaatlus forum, where the computer parts are sold,
and judging "a PC whose memory is worth it once the rest is resold" needs
a model rather than a keyword.

The judging runs on our Claude subscription, which costs nothing more if
the model runs only when there is something to judge. A job every ten
minutes needs the free Actions minutes of a public repo: the private pool
is spoken for by the trip atlas and the stories (ADR-037). Each of us talks
to the job in a private Telegram chat: alerts arrive there, and a plain
sentence there asks for a new search.

## Decision

1. **An unattended job under ADR-027 points 4-6 that takes requests from
   allowed chat users.** It runs in the public repo `khe-deals` on
   GitHub-hosted runners. Collection runs every ten minutes with no
   model; Claude judges the waiting listings in a batch a few times a day
   and answers a free-text message in a job of its own per sender, which
   sees only that sender's watches. Only chat users listed in an
   environment secret are heard; anyone else is reported to us once.
2. **It writes two things: Telegram messages and the users' own watch
   files** (with their price and feedback lines) in the private data repo
   `khe-deals-watches`. It is a content writer like ADR-037 point 4, not
   the builder of ADR-027 point 7, so ADR-023 stands. A watch change is
   committed only after its owner confirms it with a command; the model
   proposes and never writes.
3. **The Claude jobs' egress allowlist is set at the tool level**, in
   place of the runner allowlist ADR-027 point 5 names as the upgrade: no
   Bash, file edits only to the job's one output file, web fetches only to
   `www.hinnavaatlus.ee` and `foorum.hinnavaatlus.ee`, and the Telegram
   and watch tokens never in a Claude job's environment. The listings and
   messages it reads are less trusted content, which is why point 5's
   upgrade is due here.
4. **A public repo with encrypted job data.** The family's messages,
   watches and replies pass between jobs and sit in the Actions cache only
   sealed with AES-256-GCM under a key in the environments; logs print no
   listing, message or model text. Fork pull request runs need approval.
   The listings are public on the forum anyway.
5. **The watch repo has no CI of its own,** an exception to ADR-001: its
   files are data that `khe-deals`' code validates on every read and
   before every write, and its local check is that same validator.
   Fine-grained tokens limited to that repo read it (contents read) and
   write it (contents write).
6. **agent-vm's sandbox host list (ADR-027 point 3) grows by the two
   Hinnavaatlus hosts**, for fixtures and live runs of the collector.
7. **A new source joins only after its own terms and robots check**,
   recorded in the plan that adds it. Login-gated marketplaces stay out.
8. **The second user's requests run on our subscription through our own
   automation**, which we accept as personal use within the household.

## Alternatives considered

- **A ready alert app:** none covers the Hinnavaatlus forum, and the
  effective price of a bundle needs a judgement no keyword gives.
- **A private repo:** about 4300 runs a month would not fit the free
  private minutes, and GitHub Free has environment secrets only in public
  repos.
- **Watches in khe-meta:** it holds the house documentation and a token
  cannot be scoped to a folder.
- **An always-on bot in the homelab:** answers at once, but a model
  reading strangers' text would run on the home network, which ADR-027
  keeps out; a ten-minute answer is acceptable.
- **A runner egress allowlist:** an action of its own to pin and keep
  working, for what the tool list already prevents.

## Consequences

- An answer takes up to ten minutes, since nothing runs between the
  scheduled runs.
- A leaked read or write token exposes or changes the search list and
  nothing else; the subscription token's risk is ADR-027 point 5's.
- Fine-grained tokens expire, so reading the watches fails on a date we
  keep in the calendar; the job then sends its failure alert.
- GitHub disables a public repo's schedule after 60 days without activity;
  Renovate's pin updates keep it active.
- The job is a writer in the register (ADR-007) with its fallback:
  disable the workflow, revoke the bot, the Claude token and both watch
  tokens, and revert watch commits.

## References

- [Telegram Bot API](https://core.telegram.org/bots/api)
- [claude-code-action](https://github.com/anthropics/claude-code-action)
