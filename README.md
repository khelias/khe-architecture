# khe-architecture

The architecture decisions of the KHE estate, the set of repos under
[github.com/khelias](https://github.com/khelias) and the homelab that runs
them. Each decision that spans more than one repo is written down here as
an architecture decision record (ADR), for publication. They are rendered,
one page each, at
[khe.ee/architecture/decisions](https://khe.ee/architecture/decisions/),
which `khe-sites` builds from this repo on every deploy and at least weekly.

## Reading an ADR

Each file in [`decisions/`](decisions/) is one decision, numbered in the
order it was made. Line 3 gives its status and date: `Proposed` is still
open, `Accepted` is in force, `Superseded` points to the ADR that replaced
it and `Moved` to the repo whose docs now hold it. The sections follow
Michael Nygard's format: the context that forced a choice, the decision,
the alternatives considered and the consequences we accepted. A narrower or
wider version of a decision edits its ADR in place and moves the date; a
reversal gets a new ADR, and the old file stays as a short stub that links
onward, so every old address keeps working.

## The numbers

[`metrics/agent-loop.json`](metrics/agent-loop.json) holds the counts behind
[khe.ee/agents](https://khe.ee/agents/): what each check of the agent loop
found and how its pushes went, refreshed when a task closes.

## The estate

[`ESTATE.md`](ESTATE.md) lists every repo in the estate, what it is for and
where it runs.

## Checks

```bash
bash scripts/check.sh
```

## License

[MIT](LICENSE)
