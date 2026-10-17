---
name: verify-on-mac
description: Run builds, tests, and linters on the Mac from knockon. Use when a change needs verification heavier than an edit or a read, and the agent runs on knockon. If the Mac is unreachable, record the pending command instead of claiming a pass.
---

# Verify on the Mac

knockon is the always-on agent host. The Mac (M5, 24 GB) is the only machine
that can build and test the work repos. The work repos have no CI.

## 1. Check reachability

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 macbook true
```

If this fails, stop. Report: "Verification pending: Mac unreachable." Write the
exact command you would have run into the PR or the handoff note. Never report a
pass without an exit code.

## 2. Push the branch first

The Mac verifies pushed code, not knockon's working tree.

```bash
git push -u origin <branch>
```

## 3. Use a detached worktree on the Mac

Do not touch the Mac's working tree. It may hold uncommitted work.

```bash
ssh macbook 'cd <repo> && git fetch origin && git worktree add --detach /tmp/verify-<id> origin/<branch>'
ssh macbook 'zsh -lc "cd /tmp/verify-<id> && <command>"'
ssh macbook 'cd <repo> && git worktree remove /tmp/verify-<id> --force'
```

Keep the worktree if the check fails, so you can inspect it.

An SSH command on the Mac starts with a minimal `PATH`
(`/usr/bin:/bin:/usr/sbin:/sbin`). Build tools live in `/opt/homebrew/bin`, so
always run the check through `zsh -lc`. Without it, `go`, `npm`, and the other
tools report "command not found".

## 4. Commands by repo

| Repo | Mac path | Command |
| --- | --- | --- |
| iit | `~/Documents/T2Knock/iit` | `go test ./...` |
| pim | `~/Documents/adam/pim` | `make test` |
| pim-ui | `~/Documents/adam/pim-ui` | `npm run typecheck && npm run lint && npm test` |
| infrastructure | `~/Documents/adam/infrastructure` | no test suite; see below |
| linko | `~/Documents/T2Knock/linko` | no tests; open the page |

`pim` tests may need OpenSearch or Temporal port-forwards. Start them with
`make opensearch-forward` and `make temporal-dev` before the test, and stop them
after.

`infrastructure` holds Grafana, Kubernetes, AWS, and GitHub resources. Verify
with `gcx resources push -p ./rules --dry-run` for Grafana and `kubectl diff`
for Kubernetes. There is no test suite.

## 5. Report

Return the command, the exit code, and the tail of the output. State which
checks passed and which did not run.
