# ADR-051: The agent on agent-vm reaches the K2 through a root-registered MCP server, and only a print asks

- **Status:** Accepted (2026-11-21)
- **Supersedes:** [ADR-050](050-the-attended-agent-slices-and-starts-k2-prints.md)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-023](023-agent-pushes-where-its-session-allows.md) (stands), [ADR-027](027-attended-and-unattended-agent-tiers.md) (point 3's list of what runs outside the sandbox loses the printer scripts and gains the managed MCP list), [ADR-043](043-household-parts-are-public-source-built-into-khe-sites.md) (the parts it prints)

## Context

ADR-050 let two printer scripts out of the agent-vm sandbox, each run on
a tap. In use, a tap on reading the printer's state or a camera frame
carried no decision; only starting a print does. Each tool that reaches
outside the sandbox also brought its own excluded command, ask rule,
root-owned copy and setup section, and the OpenSCAD pin sat in both the
parts repo's CI and the VM setup, the OrcaSlicer pin only in the setup.

Claude Code's sandbox covers shell commands only; a local MCP server runs
outside it with our user's access. The Grafana server on the VM already
did, started from the session-writable checkout. A managed MCP file
owned by root takes exclusive control: servers registered any other way
stop loading and adding one fails. A tool that marks itself as needing
user interaction prompts on every call, ignores allow rules and applies
in auto mode. A tool may return an image, seen inline.

## Decision

1. **Slicing and rendering run on agent-vm inside the sandbox**, with
   pinned, checksummed OrcaSlicer and OpenSCAD builds, as ADR-050 point 1
   had it. Each pin lives in the repo that uses the tool: OpenSCAD's in
   the parts repo's CI, OrcaSlicer's beside its slicer profiles. The VM
   setup reads them from there instead of holding a copy.
2. **The VM's MCP servers are an exclusive list in a root-owned managed
   file, and each runs a root-owned copy.** The setup script writes the
   list and installs the copies out of the workspace; a change takes
   effect when we rerun it and accept the diff it shows. No session can
   add a server or change the code one runs, though every server runs
   outside the sandbox.
3. **The printer is one MCP server.** Its state, its files, the chamber
   light, camera frames and an upload run without a tap, since none of
   them starts anything. Starting a print carries the forced-confirmation
   flag in the server's own code, so no settings rule can lift that
   prompt. A device the agent reaches later gets a server of its own the
   same way, not a script let out of the sandbox.
4. **A print starts only on our go for that file in our latest message,
   and only when the printer is idle.** The server refuses unless Klipper
   is ready and no print is running or paused, refuses any file whose side
   fan exceeds the value the printer once capped it at, and fails unless
   the printer reports the print as started. An upload and a print read
   only an absolute path to a plain file in the workspace or the session's
   temporary folder, opened without following a link.
5. **No writes to the printer's configuration, no Klipper restart and no
   firmware change** from the server. A remote restart once shut the
   printer down with a motor fault.
6. **The code that runs outside the sandbox cannot be changed by the
   session that uses it**: point 2's copies, with only those listed.
7. **The printer's address on the VM sits in the private configuration
   folder** that sandboxed commands cannot read, copied there by us.

## Alternatives considered

- **The two scripts with narrower ask rules:** a tap would stay on every
  read, or an allow rule on a shell pattern would let a read through that
  a crafted command line could widen; the prompt would rest on settings a
  session's own changes could reach.
- **A server registered in user scope:** a session can rewrite the user
  configuration and the code it points at, and add servers of its own.
- **A third-party printer MCP server:** its tools start prints with no
  forced prompt and write the printer's configuration; we would audit and
  pin someone else's code that runs with home-network reach.
- **An MCP library:** a package installed as root from a registry for a
  protocol that is newline-delimited JSON-RPC, against printer code that
  needs only the standard library.

## Consequences

- Reading the printer and looking through its camera from the phone no
  longer need a tap; the one prompt left means a print.
- Checking the bed through the camera and saying "print" for that file
  stay ours; the prompt does not replace looking at the bed.
- An untapped upload can put only the named plain file on the printer.
- If the managed file fails to load under Remote Control, the agent loses
  Grafana and the printer until it is fixed or removed.
- A change to a server reaches the VM only through a setup rerun, which
  also runs repository build code with the VM's sudo, as ADR-027 accepts.
- Fallback: delete the managed MCP file on the VM, revert the setup and
  settings template changes and rerun the setup. The laptop keeps the
  printer's command-line tool with the same commands and output.

## References

- [khe-homelab `infrastructure/agent-vm.md`](https://github.com/khelias/khe-homelab/blob/main/infrastructure/agent-vm.md)
- [Claude Code MCP: managed configuration](https://code.claude.com/docs/en/mcp)
- [Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing)
