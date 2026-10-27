---
name: agent-browser-isolated
description: >-
  Use the isolated Chrome for Testing profile when a task must not touch the user's logged-in
  browser: untrusted pages, throwaway scraping, or parallel browser work. Read the `browser`
  skill first; it owns lane selection and the rules.
---

# agent-browser, isolated lane

This is the isolated lane only. It has its own profile at
`~/.agent-browser/profiles/ht2knock-work`, separate from the user's Helium profile. It has no
access to the user's logins. That is the point of this lane.

## Rules that matter here

- One named session per task: `agent-browser --session <name> ...` on every call.
- Load the version-matched reference once: `agent-browser skills get core`.
- Wait on an element, text, or URL. Do not use `wait --load networkidle` on a single-page app.
- Re-snapshot after every navigation. Refs such as `@e12` go stale.
- Close the session with `agent-browser close`.

Do not kill a browser process, delete `SingletonLock`, or read the cookie database. See the
`browser` skill for the full rule list and the failure playbook.
