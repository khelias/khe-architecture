# khe-architecture

[![CI](https://github.com/khelias/khe-architecture/actions/workflows/ci.yml/badge.svg)](https://github.com/khelias/khe-architecture/actions/workflows/ci.yml)

The architecture decisions of the KHE estate, the set of repos under
[github.com/khelias](https://github.com/khelias) and the homelab that runs
them, written down for anyone who wants to see why it is built the way it
is. Each decision that spans more than one repo is an architecture decision
record (ADR) here, rendered one page each at
[khe.ee/architecture/decisions](https://khe.ee/architecture/decisions/).

## How it works

Each file in [`decisions/`](decisions/) is one decision, numbered in the
order it was made. Line 3 gives its status and date: `Proposed` is still
open, `Accepted` is in force, `Superseded` points to the ADR that replaced
it and `Moved` to the repo whose docs now hold it. The sections follow
Michael Nygard's format: the context that forced a choice, the decision,
the alternatives considered and the consequences we accepted. A narrower or
wider version of a decision edits its ADR in place and moves the date; a
reversal gets a new ADR, and the old file stays as a short stub that links
onward, so every old address keeps working.

[`ESTATE.md`](ESTATE.md) lists every repo in the estate, what it is for and
where it runs. [`metrics/agent-loop.json`](metrics/agent-loop.json) holds
the counts behind [khe.ee/agents](https://khe.ee/agents/): what each check
of the agent loop found and how its pushes went, refreshed once a week.

## Run it

There is no build. The check of every ADR's format and links, and of the
estate index and the numbers, is:

```bash
bash scripts/check.sh
```

## Where it runs

Nothing here deploys.
[khe-sites](https://github.com/khelias/khe-sites) builds its architecture and
agents pages from this repo on every deploy and at least weekly.

## More

- [AGENTS.md](AGENTS.md) - what belongs here and the rules an ADR follows

## Licence

MIT, see [LICENSE](LICENSE).
