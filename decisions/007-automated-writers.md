# ADR-007: One rule for automated writers

- **Status:** Proposed (2026-10-02)
- **Related:** [ADR-004](004-app-backend-and-identity.md), [ADR-008](008-container-images.md)

## Context

An automated writer is anything that changes state without a person at the
keyboard: a dependency bot that merges, a job that deletes old backups, a
heating automation. Every repo in the estate has some, and so does the house
it runs in.

The estate already has a rule for each of them, in several places with
different wordings: [ADR-004](004-app-backend-and-identity.md) point 5
(automated sources write proposals a person accepts), the AI coding agent's
setup (the agent prepares commits, a person pushes), each repo's Renovate
automerge rules, and the house automations (they only notify, with named
exceptions). Since [ADR-008](008-container-images.md) a GitHub App
automerges image pins into `khe-homelab`, which deploys to production with
no person in the loop.

Every planned feature adds writers: scheduled maintenance agents, a trip
assistant and imports from other services, adaptive study scheduling,
predictive heating. A heating automation is the first writer whose mistake
is physical.

## Decision

An automated writer works in one of two modes:

1. **Proposes.** It prepares a change and a person accepts it: a local commit
   a person pushes, a PR a person merges, a proposal in an app's revision
   log, a notification a person acts on.
2. **Acts.** It changes state alone, and then it needs both:
   - a **written envelope**: what it may change and under which checks, in a
     file someone can review, not only as a condition inside the automation;
   - a **named fallback**: the written way back, or the safe state it falls
     to, when it fails or gets it wrong. Detecting a problem is not a
     fallback.

The register of writers, with each one's mode, envelope and fallback, is
kept with the estate roadmap. A new writer is added to it in the same change
that adds the writer, and a writer that acts without a named fallback is
recorded there as an open item until it has one.

## Alternatives considered

- **Keep the rule per place.** It works while each place is small, but every
  new writer is then argued from scratch, and the envelope stays a condition
  inside an automation that nobody reviews.
- **No writer acts alone.** Safe, but it would put a person in front of
  every dependency update and every deploy, which the working loop of
  [ADR-006](006-branch-protection.md) deliberately avoids.

## Consequences

- Once accepted, a new writer cites this ADR and joins the register.
- A writer whose mistake is physical, such as heating control, writes only
  after its envelope and fallback are written and reviewed.
- Writers that act today without a written fallback become visible as open
  items for the repos that own them.
- Risk: ceremony. The rule is one page, and it is worth it only if new
  writers are checked against it.
