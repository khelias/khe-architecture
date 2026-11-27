# ADR-027: Attended agent sessions with Home Assistant control, unattended jobs on GitHub-hosted Actions

- **Status:** Accepted (2026-11-27)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-023](023-agent-pushes-where-its-session-allows.md), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (a content writer under points 4-6)

## Context

The agent is to build and maintain the estate while we steer and approve
from the phone. `agent-vm`, a Debian VM in the homelab, runs our Claude
Code workspace agent through Remote Control, always on and in auto mode.

A session a person steers has someone who can answer a prompt. A job on a
schedule has nobody to ask and reads text other people wrote, so it is
where a prompt injection would arrive. The VM user has sudo, so no boundary
inside the VM holds against a session that was talked into misusing it.

## Decision

The VM's sandbox, hosts, keys and servers are in khe-homelab's
[agent-vm runbook](https://github.com/khelias/khe-homelab/blob/main/infrastructure/agent-vm.md),
the jobs' tokens in its
[SECURITY.md](https://github.com/khelias/khe-homelab/blob/main/SECURITY.md#automated-writers).

1. **Two tiers, split by whether a person is in the session.** The attended
   tier is any session we start and steer, on `agent-vm` or our laptop, and
   those it starts at our word, even while we sleep, since what asks still
   waits for us. The unattended tier is any job that runs without us, in
   GitHub-hosted Actions with Anthropic's Claude Code action, never on
   `agent-vm` or the homelab's runner.
2. **The attended tier controls Home Assistant.** Its envelope under
   [ADR-007](007-automated-writers.md): every Home Assistant write asks us,
   in auto mode too, and none touches the heat pump or ventilation, which
   the house's writer register reserves. Fallback: revoke the token.
3. **The attended tier's Bash on `agent-vm` runs in Claude Code's sandbox
   in strict mode,** with no unsandboxed retry, outbound traffic only to a
   fixed list and the keys out of its reach. A few commands written alone
   run outside it, and each asks. MCP servers run outside it too, so the
   VM's are a root-owned list, each running a root-owned copy no session
   can change until we rerun the setup and accept its diff; a new device
   gets such a server. A blocked command is fixed in the VM's template,
   never by a session.
4. **An unattended job never holds a write token while a model runs.** Each
   job is two: one runs Claude with a token that can only read and a fixed
   tool list, and hands its output on as an artifact; a second, with no
   model, checks that output (size, secrets, personal data, mentions) and
   makes the one write the job exists for. Workflow permissions, enforced
   by GitHub, are the boundary; the Claude GitHub App stays uninstalled.
5. **Inference uses our Claude subscription token,** usable only from
   `main` and kept from the commands Claude runs. The Claude job's outbound
   traffic is open, so an injected run could send the token out and spend
   the subscription until it is revoked, which we accept. An egress
   allowlist is the upgrade if a job reads less trusted content.
6. **Every action is pinned by commit, every job has a timeout,** runs one
   at a time, and has a turn limit. Each unattended job is a writer in the
   register with its envelope and fallback.
7. **Growth path.** First a weekly digest that opens one issue and pushes
   no code, under [ADR-023](023-agent-pushes-where-its-session-allows.md).
   Next a builder that opens a PR for an issue we label, gated by required
   checks and our merge, which changes ADR-023. Last, auto-merge for change
   classes measured data shows safe. The homelab changes only through a
   merged PR and its deploy; this tier never holds docker-vm or house keys.
8. **An unattended job may run on the plan's API credits,** from its own
   API client instead of point 1's action and with a spend-capped key
   instead of point 5's token; point 4 holds. The credits expire unused and
   do not cover Claude Code, and the weekly limit stays with our sessions.
   [khe-deals](https://github.com/khelias/khe-deals) is the first.

## Alternatives considered

- **An unattended runner on `agent-vm`, a second VM or the homelab's
  runner:** sudo undoes any boundary inside the VM, a second VM fixes only
  that, all three reach the LAN and the runner deploys to production.
  Revisit when a job must reach the homelab.
- **Cloud routines:** the Claude GitHub App they need writes past the gate.
- **The attended tier without the sandbox:** in auto mode the classifier,
  not a person, approves most commands; the sandbox keeps the keys and the
  LAN out of their reach.
- **MCP servers registered by the session:** a session could rewrite them
  and their code, which runs outside the sandbox.

## Consequences

- A host off the list needs a reviewed template commit, not a prompt.
- Unattended jobs cannot read anything on the LAN; what they need from the
  homelab has to be in GitHub already.
- The subscription token and each API key in GitHub are credentials to
  revoke when the plan changes hands.
- Sessions on our laptop run without point 3's strict sandbox; the commit
  gate and the prompts that wait for us are their limit. Nothing schedules
  them, so ADR-023's revisit on unattended pushes is not reached.
