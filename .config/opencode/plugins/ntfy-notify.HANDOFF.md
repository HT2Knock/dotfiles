# Handoff: OpenCode ntfy notifications

Date: 2026-11-08. Work continues in the dotfiles repository.

## State

- Plugin: `https://github.com/HT2Knock/opencode-ntfy`, commit `404b0a7`.
- Installed on the Mac at `/Users/ht2knock/personal/opencode-ntfy` and on
  `knockon` at `~/workspace/github.com/ht2knockA/opencode-ntfy`.
- Config on each host: `~/.config/opencode/ntfy.json`, mode 600, gitignored.
  Keys: `server`, `topic`, `routineTopic`, `token`, `holdMs`, `quiet`.
- The `ntfy` CLI is installed on both hosts. Client config at
  `~/.config/ntfy/client.yml` uses `default-host` and **`default-token`**. The
  key `access-token` does not work.
- The plugin is verified. A tool call from each host produced exactly one push
  on `lab`, with near real time delivery to the phone.

## What works

- `permission.asked` and `form.created` wait `holdMs` (60 s), then send if still
  open. A reply cancels the held push.
- `session.execution.failed` sends at once.
- Quiet hours 22:30–06:00 Asia/Ho_Chi_Minh suppress event pushes.
- A `notify` tool sends a push or a delayed reminder.
- Child sessions and other locations are filtered. Duplicate events are claimed
  once per process and once in plugin storage with a 48 h TTL.

## Host state

- `knockon` OpenCode runs under `opencode.service`, version 2.2.6 from the
  `opencode-beta` package at `/usr/bin/opencode`.
- The unit is `Type=simple`, `ExecStart=/usr/bin/opencode serve --service`,
  `Restart=always`. It took several attempts to find this shape; see the traps.
- kimaki is stopped and disabled. Its old routines are not migrated. The
  `~/.kimaki` data and the kimaki plugin directories are still on disk.
- `knockon` default model is `opencode-go/deepseek-v4.1-flash`. The OpenAI
  default returned `provider.auth` 400 (see issue 55211). The OpenAI credential
  is still stored.
- The `always-on.service` unit blocks idle, sleep, and lid suspend.

## Open work

1. Phase 3: the workout coach.
   - Write a lean `routines/workout-coach.md` in `JT-notes`.
   - Run it from a systemd user timer at 05:45.
   - The runner owns delivery: `opencode run --format json`, extract the text
     between `<<<NOTIFY` and `NOTIFY>>>`, publish to `routine` with the CLI.
     Do not let the model call the tool; the runner is deterministic.
   - Pin `--model opencode-go/deepseek-v4.1-flash`. Do not use `--archived`;
     `knockon` 2.2.5 lacked it, and the version is now 2.2.6.
   - Remove the old kimaki routines and the `~/.kimaki` data after one good run.
2. Phase 5: add `knockon` to the phone web UI with **Add Server**
   (`opencode pair --remote` gives the OpenTunnel origin). The Mac is already
   added.
3. Dotfiles: the Mac commit contains the plugin path, the `.gitignore` entry,
   and this handoff. `knockon` has uncommitted unit changes in its own clone.
4. Optional: report the `plugin add` bug (see below) and transfer nothing else.

## Traps

- **`opencode plugin add` cannot install any Git package.** It fails with
  `NpmInstallFailedError` / `git dep preparation failed` on 2.2.6 stable and on
  `opencode-beta 2.2.6-1`, including for `github:sindresorhus/is-odd`. Use a
  local clone plus a path in `plugins`. Exists as issue 49704 (open,
  `reproduced`); 55073 was closed as a duplicate.
- **`opencode serve --service` must run as `Type=simple`.** With `Type=forking`
  systemd times out. With `Type=simple` and a held port it exits 0, so
  `Restart=always` enters a loop. Free the port first.
- **kimaki starts its own OpenCode server** if the port is free. Stop kimaki
  before working on the service.
- **`opencode service restart` on `knockon` fights systemd.** Use
  `systemctl --user restart opencode`.
- **The `ntfy` CLI config key is `default-token`.** `access-token` is silently
  ignored and the server returns 403 under `deny-all`.
- **The Mac web UI needs a Chromium-based browser on iOS 15.** Safari renders a
  black page. Reynard works but drains battery while the event stream is open.
- **A modified plugin file is not re-imported.** Restart the server after a
  build.

## Files

- Plugin source: `~/personal/opencode-ntfy` (Mac), `dist/` is committed.
- Plugin config: `~/.config/opencode/ntfy.json` (not in git).
- CLI config: `~/.config/ntfy/client.yml` (not in git).
- Unit: `knockon`: `~/dotfiles/.config/systemd/user/opencode.service`.
- Tech note: `JT-notes/tech/ntfy-opencode-push.md`.

## Suggested skills

- `opencode` for the V2 config, plugin, and service APIs.
- `diagnosing-bugs` if a push does not arrive.
- `technical-writing` for the routine prompt or the tech note.
- `report` for the `plugin add` bug.
