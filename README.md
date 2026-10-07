# khe-architecture

The architecture decisions of the KHE estate, the set of repos under
[github.com/khelias](https://github.com/khelias) and the homelab that runs
them. Each decision that spans more than one repo is written down here as
an architecture decision record (ADR), for publication: they will be
rendered at [khe.ee/architecture](https://khe.ee/architecture) once that
page exists.

## Reading an ADR

Each file in [`decisions/`](decisions/) is one decision, numbered in the
order it was made. Line 3 gives its status and date: `Proposed` is still
open, `Accepted` is in force, `Superseded` points to the ADR that replaced
it. The sections follow Michael Nygard's format: the context that forced a
choice, the decision, the alternatives considered and the consequences we
accepted. An accepted ADR is not rewritten; a changed decision gets a new
ADR.

## The estate

[`ESTATE.md`](ESTATE.md) lists every repo in the estate, what it is for and
where it runs.

## Checks

```bash
bash scripts/check.sh
```

## License

[MIT](LICENSE)
