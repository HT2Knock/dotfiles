---
name: browse
description: >-
  Drive the user's real browser when a page needs their session, a rendered UI,
  a click, or a step only they can do. Use it when the user says "my browser" or
  names a page they are signed into. Reach for webfetch first on a public page.
---

# browse

`browse` drives the user's real browser. Every site they are signed into is
already open to you. Agent tabs open in the background, in one collapsed group,
and close when idle.

## Rules

1. **Pass the tab on every call.** Name it when the task outlives one call:
   `tabs({ action: "new", id: "pim", url })`. Work in tabs you opened or the
   user lent; `tabs` marks which are which.
2. **Read, then act.** `snapshot` gives refs such as `e12`. Click and fill by
   ref. A guessed selector waits its full timeout on a control that was not
   there.
3. **Read again after a navigation or a handoff.** A handoff returns when the
   user clicks Continue, and the page has usually redirected by then. Old refs
   are gone with the old page. `wait_for` text or a URL when the page is still
   loading.
4. **Keep secrets inside the page.** Act on a token or cookie there. A value you
   return enters the transcript.

Open a page you trust with the user's logins. Ask first when you do not.

## Loop

```js
const { tab } = await tools.browse.tabs({
  action: "new",
  id: "pim",
  url: "https://adam.airrlabs.com",
  group: "pim",
});
const outline = await tools.browse.snapshot({ tab });
await tools.browse.click({ tab, ref: "e12" });
```

Done when a fresh snapshot shows the value you came for. A click that returned
is not proof.

## The tab is the handle

`tabs` returns `tab`, and every tool takes it. These options stick to the tab:

| Option           | Effect                                                                |
| ---------------- | --------------------------------------------------------------------- |
| `group`          | A label; `tabs` with `action: "close"` closes the group at once       |
| `allowedOrigins` | Limits top-level navigation only; a page's own requests still go out  |
| `readOnly`       | Refuses input and later navigation; `eval` still runs page JavaScript |
| `keepOpen`       | Survives idle cleanup, until you or the user close it                 |
| `keepVisible`    | Keeps the page focused for apps that pause while hidden               |
| `browser`        | Picks one connected browser by id                                     |

`readOnly` and `allowedOrigins` are guardrails, not a data boundary.

## Handoff

Use `handoff({ tab, message })` for a login, 2FA, a passkey, a captcha, or a
payment. One or two plain sentences, then wait. `outcome` is `continued`,
`timeout`, `closed`, or `cancelled`. Snapshot after every `continued`.

Never solve a captcha. Hand it off.

## Capture

`screenshot` and `screenshot_diff` for visual evidence, `network` for a request
flow with credentials redacted, `console` for errors, `recording` for a video,
`demonstrate` to record a flow the user performs.

## Setup and repair

`browse status` shows the relay, the extension, and the agent entry. If the
tools are missing after an install, restart the agent. `browse install` repairs
the pairing.
