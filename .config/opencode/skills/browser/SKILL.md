---
name: browser
description: >-
  Drive the user's real Helium browser, or an isolated browser, from an agent. Use when a page
  needs the user's logged-in session, when a JavaScript app renders only in a browser, when you
  must click or fill a running UI, when a step needs 2FA or a CAPTCHA, or when you capture an
  authenticated request. To prove that UI code works, write an e2e test instead.
---

# Browser

Two lanes. Pick one before the first command.

| Lane | Tool | Profile | Use for |
| --- | --- | --- | --- |
| Real | `browser_control` MCP tools | Helium `Default`, 406 domains logged in | Authenticated apps, the user's open tabs, 2FA |
| Isolated | `agent-browser` CLI | `~/.agent-browser/profiles/ht2knock-work` | Untrusted pages, throwaway scraping, parallel work |

Choose the isolated lane when unsure. The real lane holds the user's live sessions.

## Hard rules

These come from past failures in this environment. Do not repeat them.

1. **Never kill the browser.** No `pkill Chrome`, no `pkill Helium`, no `killall`. The real
   browser holds the user's tabs. Use `agent-browser close` or the session delete tool.
2. **Never delete `SingletonLock` or touch the profile directory.** A lock means a running
   browser. Close it through the tool.
3. **Never read the cookie database with `sqlite3`.** Do not copy a browser profile. Use the
   tool's own session.
4. **Never put a token, cookie, or password in a command or in `execute` code.** Journals keep
   previews. Read a value into a variable inside the page, and do not print it.
5. **Name the session.** One task, one session. A shared default session causes the wrong tab.
6. **Re-snapshot after every navigation.** Refs such as `e138` go stale and `Unknown ref` is the
   most common failure.
7. **Wait on a condition, not on time.** See *Waits*.

## Lane 1: real browser

Use the `browser_control` MCP tools. Call `browser_control.skill()` once if you need the full
upstream workflow.

```text
status            -> relay and extension reachable?
execute           -> run Playwright code, one page
session_new       -> named session, optional readOnly
session_adopt     -> take over a tab the user attached
session_delete    -> close tabs this session opened
```

Workflow:

1. `status`. If `connected` is false, run `browser-control doctor` and report the result. Do not
   start a second relay.
2. If the user already has the page open: ask them to click the Browser Control toolbar button,
   then `session_adopt({ targetUrl: "site.com" })`. Do not replay a login.
3. `execute({ code: "return await snapshot()" })` to read the page. Act with `ref("e12")`.
4. Verify with a fresh read or `page.url()`. A successful click is not proof.
5. `session_delete` when the task ends.

Use `handoff()` for 2FA, CAPTCHA, a passkey prompt, or a payment confirmation. Never try to
automate those. Always check the expected URL or element after the handoff.

## Lane 2: isolated browser

Read the version-matched reference once per session:

```bash
agent-browser skills get core
```

Then set one session for the whole task:

```bash
agent-browser --session "$(agent-browser session id --scope worktree --prefix <task>)" open <url>
```

Keep `--session <name>` on every call when you already know the name. `AGENT_BROWSER_SESSION`
also works, but it does not survive a new shell.

Loop: `open` → `snapshot -i` → act on `@e1` → wait → `snapshot -i` again.

Close the session when done: `agent-browser close`.

## Waits

Use the condition that marks readiness:

```bash
agent-browser wait @e1
agent-browser wait --text "Saved"
agent-browser wait --url "**/dashboard"
```

Do **not** use `wait --load networkidle` on a single-page app. These apps keep sockets open, so
networkidle times out while the page is already usable. This was the most repeated mistake in
history: 252 calls, 2 correct text waits. Use a fixed `sleep` only to reproduce a timing bug.

## Failure playbook

| Symptom | Cause | Action |
| --- | --- | --- |
| `Unknown ref: e138` | Page changed after the snapshot | `snapshot` again, then use the new ref |
| `daemon already running` / `--headed ignored` | A session is still open | `agent-browser close`, then retry |
| `Daemon version mismatch` | CLI upgraded under a live daemon | Let it restart, then re-run the command |
| `net::ERR_CERT_COMMON_NAME_INVALID` | Scheme or host differs from the app | Use the exact origin the app serves |
| `net::ERR_NAME_NOT_RESOLVED` | Wrong host or port | Check the running dev server before retrying |
| `401` / `Not authorized` | Wrong profile or expired session | Lane 1: adopt the user's tab. Do not re-login |
| Empty snapshot after navigation | Page still booting | Wait for an element or URL, then re-snapshot |

## Screenshots

Write to the session temp directory, not `/tmp`:

```bash
agent-browser screenshot "$TMPDIR/opencode/page.png"
```

## When not to use this skill

To prove that UI code works, write a deterministic e2e test with the project runner. Driving the
live UI is not evidence. Use this skill to reach a page, or to check behaviour that only exists
in the deployed environment.
