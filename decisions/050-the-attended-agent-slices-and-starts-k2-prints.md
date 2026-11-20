# ADR-050: The attended agent on agent-vm slices parts and starts K2 prints, each printer command on a tap

- **Status:** Accepted (2026-11-20)
- **Related:** [ADR-007](007-automated-writers.md), [ADR-023](023-agent-pushes-where-its-session-allows.md) (stands), [ADR-027](027-attended-and-unattended-agent-tiers.md) (point 3's list of what runs outside the sandbox grows by the two printer scripts), [ADR-039](039-family-deal-alerts-are-an-unattended-job.md) (the same kind of change to point 3), [ADR-043](043-household-parts-are-public-source-built-into-khe-sites.md) (the parts it prints)

## Context

The household's parts are OpenSCAD source (ADR-043), printed on a
Creality K2 with a four-slot filament unit. Until now the whole chain ran
on the laptop: the agent rendered and sliced there, and a print started
only on our explicit go for that file. We kept printer control servers
out, because a tool an agent can call on its own to start a print breaks
that go rule; the rule itself came from a print the agent started while
we still wanted to talk about the design.

Most sessions now run on `agent-vm` from a phone (ADR-027), where none of
this works: Bash runs in a strict sandbox whose network list holds no
home-network host, the VM has no slicer and no current OpenSCAD, and the
printer's address and the camera tool lived with the laptop's apps.

OrcaSlicer 2.5 fixed the command-line bug that dropped per-object
filaments when the filament colours were not given, and its command-line
slicing needs no display. One slicer on the VM can now do what the laptop
needed two for.

## Decision

1. **Slicing and rendering run on agent-vm inside the sandbox.** The
   setup script installs pinned, checksummed OrcaSlicer and OpenSCAD
   builds. They need no network, so the sandbox's host list does not
   change. A slicing script checks every fan line of each slice against
   the recipe that has printed well and fails a slice that differs.
2. **Two printer scripts run outside the sandbox, and every run asks
   us.** One reads the printer's state and files, uploads or starts a
   sliced file and switches the chamber light on or off for the camera,
   with two fixed commands; the other saves frames from the printer's
   camera. Each is
   an `excludedCommands` entry written alone and an `ask` rule in the VM's
   settings template, the way the Home Assistant scripts are (ADR-027
   point 3). The tap is our go for that run, on top of the agent's own
   rule.
3. **A print starts only on our go for that file in our latest message,
   and only when the printer is idle.** The print script refuses unless
   Klipper is ready and no print is running or paused, refuses any file
   whose side fan exceeds the value the printer once capped it at (the VM
   cannot check whether the cap is in place, so the limit holds always),
   and fails unless the printer reports the print as started.
4. **No writes to the printer's configuration, no Klipper restart and no
   firmware change** from either script. A remote restart once shut the
   printer down with a motor fault.
5. **The scripts that run outside the sandbox cannot be changed by the
   session that runs them.** A changed script would run with the VM's
   home-network reach and keys while the tap shows only its command line.
   So the setup script copies them, root-owned, out of the workspace, and
   the template lets only those copies out of the sandbox. A change in the
   repo takes effect when we rerun the setup script and accept the diff it
   shows.
6. **The printer's address on the VM sits in the private configuration
   folder** that sandboxed commands cannot read, copied there by us.

## Alternatives considered

- **The printer's address on the sandbox's host list:** every sandboxed
  command would reach the printer, with no tap.
- **A printer control MCP server:** more to run and keep up for the same
  reach, and its tools are called without a prompt.
- **Creality Print on the VM:** its command-line crash is fixed in the
  current release, but it would be a second slicer to keep for what
  OrcaSlicer 2.5 now does. It stays the laptop's fallback.
- **PrusaSlicer:** no profile for this printer and its filament unit; the
  colour change would be an untested port.
- **Keep printing on the laptop only:** the sessions we steer from the
  phone could not finish a part.

## Consequences

- A part can go from source to print in one session steered from the
  phone, with a tap for each printer command.
- Checking the bed through the camera and saying "print" for that file
  stay ours; the tap does not replace looking at the bed.
- A change to a printer script reaches the VM only through a rerun of its
  setup script. The copies hold against a session; a setup rerun also runs
  repository build code with the VM's sudo, which ADR-027 already accepts.
- Fallback: remove the printer and slicer entries from the VM's settings
  template, rerun its setup and delete the printer's address file. The
  laptop's slicers stay as they are.

## References

- [khe-homelab `infrastructure/agent-vm.md`](https://github.com/khelias/khe-homelab/blob/main/infrastructure/agent-vm.md)
- [OrcaSlicer pull request 16867](https://github.com/OrcaSlicer/OrcaSlicer/pull/16867)
