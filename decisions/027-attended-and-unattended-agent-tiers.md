# ADR-027: Attended agent sessions run on agent-vm with Home Assistant control, unattended jobs on GitHub-hosted Actions

- **Status:** Accepted (2026-11-14)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-023](023-agent-pushes-where-its-session-allows.md), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (a content writer under points 4-6), [ADR-039](039-family-deal-alerts-are-an-unattended-job.md) (a content writer under points 4-6 with a tool-level egress allowlist; adds two hosts to point 3), [ADR-040](040-deal-alerts-call-the-claude-api-on-the-plans-api-credits.md) (replaces points 1 and 5 for the deal alerts: the Claude API with a key, not `claude-code-action` on the subscription)

## Context

The goal is that the agent builds and maintains the estate while we steer
and approve from the phone. `agent-vm`, a Debian VM in the homelab, runs
our Claude Code workspace agent through Remote
Control: always on, in auto mode, with the GitHub, Grafana and docker-vm
access the laptop agent has, but without its Home Assistant token and
without anything that runs when nobody is there.

Two kinds of work need different boundaries. A session a person starts
and steers has someone who can answer a prompt. A job that runs on a
schedule has nobody to ask, reads text that other people wrote (release
notes, PR bodies, logs), and so is where a prompt injection would arrive.

The VM user has sudo, so no boundary inside the VM holds against a session
that was talked into misusing it. Building an unattended runner there
(systemd hardening, an egress proxy, a GitHub App of our own and posting
units run as another user) was designed and reviewed: it needed many
mechanisms that would have to be proved on this VM, all to open one issue a
week, and it would still sit on the home network.

## Decision

1. **Two tiers, split by whether a person is in the session.** The
   attended tier is any session we start and steer on
   `agent-vm`, from the phone, claude.ai or the laptop. The unattended tier
   is any job that runs without us; it runs in GitHub Actions on
   a GitHub-hosted runner with Anthropic's `claude-code-action`, never on
   `agent-vm` and never on the homelab's self-hosted runner.
2. **The attended tier controls Home Assistant.** It holds the HA token the
   laptop agent has. Its envelope under [ADR-007](007-automated-writers.md):
   every run of the HA scripts asks us, in auto mode too; it
   writes no heat pump or ventilation setting, which the house's writer
   register reserves for a decision of its own. Fallback: remove the token
   from the VM and revoke it in Home Assistant.
3. **The attended tier's Bash runs in Claude Code's sandbox in strict mode.**
   No unsandboxed retry and no per-command extra host; outbound traffic only
   to a fixed list (GitHub, npm, PyPI, Anthropic, Debian); the ssh keys, the
   HA and Grafana tokens and Claude's credentials are unreadable to
   sandboxed commands and to the Read tool. The gh token stays readable,
   because `gh` and git need it. Only `ssh`, `scp` and the HA scripts run
   outside the sandbox, each written alone, and each asks. A command the
   sandbox blocks for a good reason gets its host or exclusion added to the
   VM's settings template, never a session override.
4. **An unattended job never holds a write token while a model runs.** Each
   job is two: one runs Claude with a `GITHUB_TOKEN` that can only read and
   a fixed tool list in the default permission mode, and hands its output on
   as an artifact; a second, with no model, checks that output (size,
   secrets, personal data, mentions) and makes the one write the job exists
   for. Workflow permissions, set in the file and enforced by GitHub, are
   the boundary; the Claude GitHub App stays uninstalled and the action
   takes the workflow token instead.
5. **Inference uses our Claude subscription token** from `claude
   setup-token`, held in a GitHub environment that only `main` can use and
   stripped from the commands Claude runs. Outbound traffic from the
   Claude job is open, so an injected run could still send the token out;
   a leak spends the subscription until the token is revoked, which we
   accept. An egress allowlist on the runner is the upgrade if a job starts
   reading less trusted content.
6. **Every action is pinned by commit, every job has a timeout,** runs one
   at a time, and has a turn limit. Each unattended job is a writer in the
   register with its envelope and fallback.
7. **Growth path.** First a weekly digest for `khe-homelab` that opens one
   issue and pushes no code; [ADR-023](023-agent-pushes-where-its-session-allows.md)
   stands for it. Next a builder: we label an issue, a workflow lets the
   agent open a PR for it, and required checks and our merge gate it; that needs an ADR superseding ADR-023. Last, auto-merge
   on green for change classes that measured data shows safe, enforced in
   CI. Infrastructure and house changes reach the homelab only through a
   merged PR and its deploy; the unattended tier never holds docker-vm or
   HA keys.

## Alternatives considered

- **An unattended runner on `agent-vm`:** sudo on the VM undoes any
  boundary inside it, the runner reaches the LAN, and the controls that
  would make it safe are ours to build and prove. Revisit when a job must
  reach the homelab, which a GitHub-hosted runner cannot and must not.
- **A second VM for unattended jobs:** fixes the sudo problem but keeps the
  LAN reach and the home-built controls, for more upkeep.
- **Claude Code cloud routines:** they need the Claude GitHub App, which
  gives cloud sessions write access past the commit gate.
- **The homelab's self-hosted runner:** it deploys to production and
  reaches the LAN; a model reading untrusted text does not belong there.
- **The attended tier without the sandbox:** in auto mode the classifier,
  not a person, approves most commands, so the sandbox is what keeps the
  keys and the LAN out of a command's reach.

## Consequences

- We approve HA writes from the phone; a session cannot change
  the house without a tap.
- Commands on `agent-vm` that need a host off the list fail until the
  template is changed, which is a reviewed commit, not a prompt.
- A screenshot of a local page works only when the server and the browser
  run in the same sandboxed command, since a sandboxed command's localhost
  is its own.
- Unattended jobs cannot read Loki or anything else on the LAN; what they
  need from the homelab has to be in GitHub already, such as a workflow's
  log.
- The subscription token in GitHub is one more credential to revoke when
  the subscription changes hands.

## References

- [khe-homelab `infrastructure/agent-vm.md`](https://github.com/khelias/khe-homelab/blob/main/infrastructure/agent-vm.md)
- [khe-homelab `SECURITY.md`](https://github.com/khelias/khe-homelab/blob/main/SECURITY.md)
- [Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing)
- [claude-code-action](https://github.com/anthropics/claude-code-action)
