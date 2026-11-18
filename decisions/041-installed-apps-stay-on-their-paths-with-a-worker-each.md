# ADR-041: Installed apps stay on their paths, each with its own worker and kill-switch

- **Status:** Accepted (2026-11-18)
- **Related:** [ADR-014](014-shared-ui-packages.md) (point 2 keeps the worker out of the shared package), [ADR-016](016-static-fallback-at-the-edge.md) (extends: no worker from the edge copy), [ADR-022](022-home-route-for-access-only-apps.md) (the saved trips open without Access), [ADR-030](030-the-portfolio-frame-and-the-product-view.md) (deviates from points 2 and 3 on the trip atlas), [ADR-031](031-stories-public-app-private-stories-audio-outside-git.md) (extends point 8)

## Context

Four apps are to be installed on phones, tablets and computers: Tarkade
Mängud, AI Seiklus, Reisipäevik and Unejänku. Each gets its own icon and
name, opens in its own window and starts without a network. Only Unejänku
has a manifest and a service worker so far.

Tarkade Mängud and AI Seiklus share the origin `games.khe.ee`, on the paths
`/study/` and `/adventure/`. A browser identifies an installed app by its
manifest `id` and limits it by its scope, but Cache Storage belongs to the
origin, so two apps there see each other's caches.

A service worker outlives the deploy that shipped it. Each site answers an
unknown path with its `index.html`, so a deleted `sw.js` returns HTML, the
browser rejects that update and the old worker keeps running. The edge copy
of ADR-016 can also answer for the origin during an outage, and would hand
out a worker from a tree that may be an hour old.

Reisipäevik sits behind Cloudflare Access. Access can refuse a device on the
road by its country or an expired session, which is when a trip is needed
most.

## Decision

1. **The apps stay on their paths.** Each has its own manifest `id`, scope
   and `start_url` on its path, and its own cache prefix. A worker deletes
   only caches under its own prefix.
2. **Each repo holds its own hand-written worker**, started from the one in
   [khe-stories](https://github.com/khelias/khe-stories). A worker is
   runtime code, which ADR-014 point 2 keeps out of `@khelias/ui`. Each app
   precaches different things and answers different failures, so a generated
   worker would need the same decisions written as configuration.
3. **A worker's precache is atomic.** Deploys delete old hashed files, so an
   install that cannot fetch every file fails, and the previous worker and
   its cache stay in use.
4. **Every worker has a tested kill-switch, and `sw.js` stays at its URL for
   good.** An app is withdrawn by deploying a worker that deletes the app's
   caches and unregisters itself, never by deleting the file. This extends
   ADR-031 point 8 to every installed app.
5. **`sw.js` is never served from the edge copy.** The edge passes it through
   to the origin, failure included, so an outage cannot install or roll back
   a worker. This extends ADR-016 point 5.
6. **A secret never enters a precache.** A file the container writes at start
   from a secret, such as AI Seiklus's `config.js`, and every API path stay
   outside the worker.
7. **The saved trips open without an Access sign-in.** Reisipäevik keeps a
   full copy of all trips on each installed device. When a navigation gets
   an Access redirect or block and a saved shell exists, the worker answers
   with the shell, and the app offers a sign-in link that goes to the
   network. Only a device that has signed in once holds the copy.
8. **Reisipäevik sets its installed view with a small script of its own**,
   in the private build only, and has no footer link. The script from
   `@khelias/ui` rejects the root path the atlas lives on, and the atlas has
   no footer. This deviates from ADR-030 points 2 and 3.

The install checklist is in
[`ESTATE.md`](https://github.com/khelias/khe-architecture/blob/main/ESTATE.md) under "Adding a repo".

## Alternatives considered

- **A subdomain per app:** every app would have an origin of its own and no
  shared Cache Storage, but the addresses already shared with teachers and
  family would change, and the games would need new tunnel routes and
  redirects to gain what a cache prefix already gives.
- **A worker in `@khelias/ui`:** one copy to fix, but it brings runtime code
  into a presentation package and ties a worker fix to a release in every
  app.
- **`vite-plugin-pwa`:** a new dependency in each app, and the rules that
  matter here (the Access redirect, the secret file, a kill-switch that
  stays) would still be written by hand.
- **Asking Access first and showing nothing when it refuses:** the safest for
  the data, but the atlas would fail on the road, where it is used.

## Consequences

- Whoever can unlock an installed device can read every trip on it without
  signing in. We accept this for a family's own devices.
- A wrong worker can hold people on an old build, so an app's kill-switch
  procedure is part of its `AGENTS.md`.
- `sw.js`, each manifest and each app's HTML are served with `no-cache`, so
  an update reaches a device on its next visit.
- A worker change is copied to each repo by hand, and the copies may drift
  apart. We accept this for four apps with different needs.
- iOS keeps a home-screen app's storage apart from Safari, so progress made
  in the browser may not carry over to the installed app.
