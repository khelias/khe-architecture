# ADR-003: The adventure proxy stays adventure-only; the pattern is copied, not the code

- **Status:** Accepted (2026-05-03)

## Context

`khe-ai-adventure`'s proxy is the estate's only AI backend. It holds the
provider keys and guards the one generation surface: origin check, HMAC,
rate limits, an exact schema-hash allowlist, retry guards, a daily spend cap
and an Estonian editor pass
([khe-ai-adventure's decision 0002](https://github.com/khelias/khe-ai-adventure/blob/main/docs/decisions/0002-proxy-and-schema-guard.md)).

Other repos may want AI output: hints or authoring assist in `khe-study`, and
an assistant that helps put a `khe-trips` trip together. The assistant would
write proposals through the trips write path proposed in
[ADR-004](004-app-backend-and-identity.md) point 5, so it needs the
proxy's guards, not its game schemas. The question is whether the proxy
becomes a shared AI spine:

- (a) extract a shared AI repo that the apps consume;
- (b) copy the pattern, not the code;
- (c) no AI outside the game;
- (d) share a service, not code: one model gateway on the homelab behind a
  versioned HTTP contract, holding provider keys, a local model and per-app
  cost accounting, while each app keeps its own guards and schemas.

## Decision

(b): the proxy stays inside `khe-ai-adventure` and serves only the game. An
app that adds AI output copies the guard pattern into its own backend, with
its own schemas, keys and limits. No shared AI library and no shared AI
service for now.

**Revisit** as (b) plus (d) when a second consumer actually ships (the trips
assistant or a study authoring assist) or a local model passes the
game's benchmark for Estonian output quality, whichever comes first.

## Alternatives considered

- (a) **Shared repo:** rejected; one library ties the apps' release cycles
  together, the same reason as [ADR-002](002-independent-stacks.md).
- (c) **No AI outside the game:** not chosen; AI output in the other apps is
  wanted, and (b) allows it without coupling.
- (d) **Shared model gateway:** deferred to the revisit trigger above. A
  service with a versioned contract couples deploys far less than a library,
  so it is the likely next step, not a rejected one. Today there is no local
  model to share.

## Consequences

- A second AI backend repeats the guard work. What can be shared without
  coupling is shared as documents instead: the eval rubric, the judge prompt
  and the golden set.
- A study feature with AI output does not have to wait for an extraction.
- Cost control and per-app cost accounting stay inside each app until (d)
  exists.
