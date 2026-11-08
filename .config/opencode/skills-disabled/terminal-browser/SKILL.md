---
name: Terminal browser
description: Drive or show a web page in a terminal pane with terminal-browser. Use when the user should see the page, or when you need snapshot, click, fill, or eval.
---

# Terminal browser

`terminal-browser` runs Chromium inside a terminal pane. The user sees the page
and can sign in; you read and act on it.

## Open

```sh
terminal-browser open <url> --split right
```

A local HTML file works the same as a URL. Without `--split`, the browser takes
over the current pane.

## Read and act

```sh
terminal-browser ls
terminal-browser action -- snapshot
terminal-browser action -- click @e14
terminal-browser action -- fill @e3 "text"
terminal-browser action -- eval "document.title"
terminal-browser action done
```

`ls` lists browsers and tabs. Target another one with
`--browser <key> --tab <id>`. `action done` clears the marker that shows the
agent is using the tab.

The step is done when the snapshot shows the expected text, or the action
changes the page in the way you named.

## Sign-in

The browser keeps its profile between runs. When a page asks for a login, ask
the user to sign in in the pane; the session stays for later runs.

## When it fails

- `ls` shows nothing: open a page first.
- `action` reports a missing tab, or the page reads as empty: stop and report
  it. A retry repeats the same failure.

Flags and edge cases: `terminal-browser <command> --help`.
