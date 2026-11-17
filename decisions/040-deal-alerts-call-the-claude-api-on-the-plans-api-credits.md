# ADR-040: The deal alerts call the Claude API from their own code, on the plan's API credits

- **Status:** Accepted (2026-11-17)
- **Related:** [ADR-027](027-attended-and-unattended-agent-tiers.md) (replaces points 1 and 5 for this job: our own client instead of `claude-code-action`, an API key instead of the subscription token; point 4 holds), [ADR-039](039-family-deal-alerts-are-an-unattended-job.md) (replaces points 3 and 8; the rest stands)

## Context

The deal alerts of ADR-039 judge listings and answer the family's
messages with `claude-code-action` on our Claude subscription token, so
every judge and every answer counts against the plan's weekly limit,
which our own sessions need. Since October 2026 the Max plan also brings
monthly credits for the Claude API, which expire unused each billing
cycle. They cover the Claude API, the Agent SDK and Managed Agents, but
not Claude Code, so not its GitHub Action either, even with an API key.
To spend them, the jobs have to call the API without Claude Code.

The jobs need little from a model harness: read one input, perhaps look
at a listing's page or a price search, and answer with one JSON file that
a model-free job then checks. Claude Code brought file, shell and web
tools that ADR-039 point 3 had to deny or narrow by configuration.

## Decision

1. **The judge and talk jobs call the Claude Messages API from khe-deals'
   own code**, with built-in `fetch` and no package, as the rest of the
   repo: streamed, with retries, on the current Sonnet. The input goes in
   the request and the answer comes back as structured output in the
   shape of the job's file; the checks of the job that acts on it do not
   change.
2. **The model has one tool, run by our code, in place of ADR-039 point
   3's tool list.** It fetches a forum topic page only when that topic is
   linked in the job's own input, and the `www.hinnavaatlus.ee` price
   search with a short query; the URL it fetches is built by our code,
   redirects are refused, and anything else is refused without a request.
   The model has no shell, no file access and no GitHub token, and the
   API key is in the one step that calls the API.
3. **Inference runs on the API credits of the Console organization linked
   to the Max plan**, with a key from a workspace of its own whose monthly
   spend limit caps what the job can use, in place of ADR-027 point 5's
   subscription token for this job. The organization holds no purchased
   credits and no auto-reload, so a job that runs out stops rather than
   costs money.
4. **The second user's requests run on these credits too**, in place of
   ADR-039 point 8: through our own key and code, under the API's terms,
   not on the subscription.

## Alternatives considered

- **Stay on Claude Code:** keeps the code as it is and keeps spending the
  weekly limit while the credits expire unused.
- **The Agent SDK:** covered by the credits and keeps today's permission
  model, but it is the Claude Code harness as a package installed in the
  job that holds the key, with its built-in tools denied by configuration
  rather than absent.
- **The official API SDK:** less of the client to write, but a package in
  the job that holds the key and the state key, in a repo that has no
  runtime dependencies and installs nothing in its jobs.
- **The API's server-side web fetch:** limited to named domains, but it
  fetches only URLs already in the conversation, so the price search
  would not work, and the request would leave from Anthropic's servers
  rather than ours.

## Consequences

- The weekly limit is no longer spent by the deal alerts.
- When the credits or the workspace limit run out, judging and answers
  stop until the next credits or the next calendar month; a candidate is
  dropped after two failed judge runs with a note to its owner, and the
  failure alert tells us.
- The streaming client, its retries and the tool loop are ours to keep
  working when the API changes.
- A leaked key spends at most the workspace's monthly limit. The fallback
  of ADR-039 revokes the API key in its Console workspace in place of the
  Claude token.
- Other unattended jobs still run Claude Code on the subscription under
  ADR-027; this decision does not change them.

## References

- [API credits for Max, Ultra, and Team plans](https://platform.claude.com/docs/en/about-claude/api-credits-for-subscribers)
- [Workspaces and their limits](https://platform.claude.com/docs/en/manage-claude/workspaces)
- [khe-deals](https://github.com/khelias/khe-deals)
