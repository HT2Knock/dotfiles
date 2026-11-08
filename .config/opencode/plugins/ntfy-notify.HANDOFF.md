# Handoff: OpenCode ntfy notifications

Date: 2026-11-08. Work continues in the dotfiles repository.

## State

- Plugin: `https://github.com/HT2Knock/opencode-ntfy`, commit `404b0a7`.
- Installed on the Mac at `/Users/ht2knock/personal/opencode-ntfy` and on
  `knockon` at `~/workspace/github.com/ht2knockA/opencode-ntfy`.
- Config on each host: `~/.config/opencode/ntfy.json`, mode 600, gitignored on
  both clones. Keys: `server`, `topic`, `routineTopic`, `token`, `holdMs`,
  `quiet`.
- The `ntfy` CLI is installed on both hosts. Client config at
  `~/.config/ntfy/client.yml` uses `default-host` and **`default-token`**. The
  key `access-token` does not work.
- The plugin is verified. A tool call from each host produced exactly one push
  on `lab`, with near real time delivery to the phone.
- `knockon` global config has the `notes` reference at `~/JT-notes`
  (commit `7093e60`).

## What works

- `permission.asked` and `form.created` wait `holdMs` (60 s), then send if still
  open. A reply cancels the held push.
- `session.execution.failed` sends at once.
- Quiet hours 22:30–06:00 Asia/Ho_Chi_Minh suppress event pushes.
- A `notify` tool sends a push or a delayed reminder.
- Child sessions and other locations are filtered. Duplicate events are claimed
  once per process and once in plugin storage with a 48 h TTL.
- Workout coach: `routines/workout-coach.md` in `JT-notes`, run by
  `~/dotfiles/scripts/workout-coach.sh` on `knockon` from
  `workout-coach.timer` at 05:45. The coach writes the message to
  `~/.local/state/workout-coach/message.txt`; the runner publishes that file to
  `routine`. Verified 2026-11-08 with two pushes.

## Host state

- `knockon` OpenCode runs under `opencode.service`, version 2.2.6 from the
  `opencode-beta` package at `/usr/bin/opencode`.
- The unit is `Type=simple`, `ExecStart=/usr/bin/opencode serve --service`,
  `Restart=always`. It took several attempts to find this shape; see the traps.
- **kimaki is removed.** The CLI processes are stopped, the unit is gone, the
  plugin directories are gone, and `~/.kimaki` is deleted. The data is archived
  at `~/.local/state/kimaki-2026-11-08.tar.gz` (18 MB). Its three routines
  (market digest, daily coach, direction coach) no longer run. The calendar sync
  that ran before the daily coach is also stopped.
- `knockon` default model is `opencode-go/deepseek-v4.1-flash`. The OpenAI
  default returned `provider.auth` 400 (see issue 55211). The OpenAI credential
  is still stored.
- The `always-on.service` unit blocks idle, sleep, and lid suspend.

## Open work

1. Phase 5: add `knockon` to the phone web UI. Run `opencode pair --remote --yes`
   on `knockon`, then scan the QR code or paste the one-time link into the
   OpenCode app. The link expires in 5 minutes; the session lasts 30 days.
2. Optional: report the `plugin add` bug (see below).
3. The Mac commit (mac-dotfile) holds the plugin path, the `.gitignore` entry,
   and this handoff. `knockon` main holds the unit, the runner, and the notes
   reference.

## Traps

- **`opencode plugin add` cannot install any Git package.** It fails with
  `NpmInstallFailedError` / `git dep preparation failed` on 2.2.6 stable and on
  `opencode-beta 2.2.6-1`, including for `github:sindresorhus/is-odd`. Use a
  local clone plus a path in `plugins`. Exists as issue 49704 (open,
  `reproduced`); 55073 was closed as a duplicate.
- **`opencode serve --service` must run as `Type=simple`.** With `Type=forking`
  systemd times out. With `Type=simple` and a held port it exits 0, so
  `Restart=always` enters a loop. Free the port first.
- **The kimaki unit state hid the real state.** `systemctl --user is-active
  kimaki` said `failed` while its CLI kept running as user processes. Check
  `pgrep -af kimaki` before you trust a unit. The unit, the plugins, and the
  data are now removed.
- **kimaki used to start its own OpenCode server** if the port was free. That
  risk is gone with kimaki.
- **`opencode service restart` on `knockon` fights systemd.** Use
  `systemctl --user restart opencode`.
- **The `ntfy` CLI config key is `default-token`.** `access-token` is silently
  ignored and the server returns 403 under `deny-all`.
- **The Mac web UI needs a Chromium-based browser on iOS 15.** Safari renders a
  black page. Reynard works but drains battery while the event stream is open.
- **A modified plugin file is not re-imported.** Restart the server after a
  build.
- **`--archived` works on 2.2.6.** The runner uses it to keep routine sessions
  out of the session list. 2.2.5 did not have the flag.

## Files

- Plugin source: `~/personal/opencode-ntfy` (Mac), `dist/` is committed.
- Plugin config: `~/.config/opencode/ntfy.json` (not in git).
- CLI config: `~/.config/ntfy/client.yml` (not in git).
- Unit: `knockon`: `~/dotfiles/.config/systemd/user/opencode.service`.
- Runner: `knockon`: `~/dotfiles/scripts/workout-coach.sh`.
- Routine units: `knockon`: `~/dotfiles/.config/systemd/user/workout-coach.service`
  and `.timer`.
- Run log: `knockon`: `~/.local/state/workout-coach/run.log`.
- Message file: `knockon`: `~/.local/state/workout-coach/message.txt`.
- kimaki archive: `knockon`: `~/.local/state/kimaki-2026-11-08.tar.gz`.
- Routine prompt: `JT-notes/routines/workout-coach.md`.
- Tech note: `JT-notes/tech/ntfy-opencode-push.md`.

## Suggested skills

- `opencode` for the V2 config, plugin, and service APIs.
- `diagnosing-bugs` if a push does not arrive.
- `technical-writing` for the routine prompt or the tech note.
- `report` for the `plugin add` bug.
