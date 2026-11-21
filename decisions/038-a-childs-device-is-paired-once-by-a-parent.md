# ADR-038: A child's device is paired once by a parent

- **Status:** Accepted (2026-11-17)
- **Related:** [ADR-004](004-app-backend-and-identity.md) (extends point 3), [ADR-022](022-home-route-for-access-only-apps.md) (amends point 4), [ADR-037](037-childrens-stories-are-made-by-an-unattended-job.md) (the first app that uses it)

## Context

ADR-004 point 3 gives every app backend its identity from the edge: a JWT
from Cloudflare Access, verified against the issuer and mapped to the
app's own user row. That fits adults and invited friends, who have an
e-mail address and can type a one-time PIN.

It does not fit our children. The stories app is the first backend they
will write to, from their own phones, and the study games plan sync for
learners from seven years old. A child has no e-mail of her own, the
Access PIN goes only by e-mail, and there is no native passkey login in
Access. At home the stories app opens on its home route (ADR-022), which
carries no Access identity at all, and ADR-022 point 4 removes a home
route as soon as a backend reads the edge identity. Its rejected
alternative, treating every request from the home network as family, is
still wrong: any device there could write.

Passkeys in an iOS home-screen web app are not confirmed to work, and the
self-hosted identity provider that could give a child an account of her
own (Authentik) waits on a RAM upgrade of the homelab host.

## Decision

1. **Two kinds of credential.** Adults and invited people keep the edge
   JWT of ADR-004 point 3. A child's device gets a credential from the
   app's own backend once a parent has paired it.
2. **Pairing is a family phrase entered on the child's device.** The
   phrase is four random words, kept only as a hash in the backend's
   configuration, and can be changed. Pairing names whose device it is.
   Pairing attempts are rate limited per address.
3. **The device credential** is 256 random bits, stored only as a hash,
   sent in a cookie that page scripts cannot read and the browser sends
   only to the app's own site, and revocable per device. The device maps to a row in the app's own store, so who may do
   what stays the app's job (ADR-004 point 4).
4. **ADR-022 point 4 is amended.** A backend may keep its app's home route
   when every write needs a paired-device credential and the backend reads
   no edge identity. A device on the home network without one can read
   what the app already serves, but cannot write. Treating home requests
   as family stays rejected.
5. **The code is written in the first app that needs it**, the stories
   app's backend. The second app moves it into a shared package then, not
   before: one use is not a pattern yet, and copies drift.
6. **The way up.** When Authentik replaces Access as the issuer (ADR-004
   point 3), a child gets an account with a passkey and pairing becomes
   one of its login methods.

## Alternatives considered

- **Access for the children:** an e-mail address each, a PIN on every new
  session away from home, and no app at home when Cloudflare is down.
- **A home route with write caps only:** fails open, which ADR-022
  rejected.
- **Authentik now:** waits on the RAM upgrade.

## Consequences

- A parent is present once per device; after that the child needs nothing
  to remember.
- Losing the backend's store means pairing each device again; the phrase
  does not change by itself.
- A leaked phrase lets any device that reaches the backend pair. Changing
  the phrase and revoking the devices it paired is the way back.
- An app with this pattern has two identities to keep apart in its logs
  and its authorization: an edge subject and a paired device.
- The study games' learner sync can reuse it on the public site, where
  there is no Access at all.
