---
name: verify-on-mac
description: Verify a change on the Mac, where the work repos build and test. Use when an edit or a read is not enough and the agent runs on knockon; when the Mac is unreachable, record the pending command instead of claiming a pass.
---

# Verify on the Mac

knockon is always on. The Mac builds and tests the work repos. The repos have no CI,
so a real command with an exit code is the only proof.

## 1. Prove the Mac is reachable

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 macbook true
```

Done when the command exits 0. If it fails, stop and report "Verification pending:
Mac unreachable", with the exact command you would have run. Report a pass only with
an exit code.

## 2. Push the branch

The Mac verifies pushed code, not knockon's working tree.

```bash
git push -u origin <branch>
```

Done when the branch is on origin.

## 3. Check in a detached worktree

Use a detached worktree, so the Mac's working tree stays untouched. It may hold
uncommitted work.

```bash
ssh macbook 'cd <repo> && git fetch origin && git worktree add --detach /tmp/verify-<id> origin/<branch>'
ssh macbook 'zsh -lc "cd /tmp/verify-<id> && <command>"'
ssh macbook 'cd <repo> && git worktree remove /tmp/verify-<id> --force'
```

Keep the worktree when the check fails, so you can inspect it. An SSH command starts
with a minimal `PATH` (`/usr/bin:/bin:/usr/sbin:/sbin`); build tools live in
`/opt/homebrew/bin`, so run every check through `zsh -lc`.

Done when the check returns an exit code.

## 4. Commands by repo

| Repo | Mac path | Command |
| --- | --- | --- |
| iit | `~/Documents/T2Knock/iit` | `go test ./...` |
| pim | `~/Documents/adam/pim` | `make test` |
| pim-ui | `~/Documents/adam/pim-ui` | `npm run typecheck && npm run lint && npm test` |
| infrastructure | `~/Documents/adam/infrastructure` | `gcx resources push -p ./rules --dry-run`, then `kubectl diff` |
| linko | `~/Documents/T2Knock/linko` | no tests; open the page |

`pim` tests need OpenSearch and Temporal port-forwards. Start them with
`make opensearch-forward` and `make temporal-dev` before the test, and stop them
after.

## 5. Report

Done when you return the command, the exit code, and the tail of the output, and
state which checks passed and which did not run.
