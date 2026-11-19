# Rex configuration

`init.lua` loads `keys.lua` and the modules in `actions/`.

- `keys.lua` holds the prefix, the key for each mode, and every global binding.
- Each `actions/` module holds one custom action. A module that declares a mode
  also holds that mode's keys.
- `actions/project.lua` opens a zoxide directory from the command palette. It
  sets `PATH` because the app runs actions with a small environment.
- `types/rex.lua` is a hand-written LuaCATS file for lua-language-server.
  `.config/nvim` loads it through lazydev. Delete it when Rex ships its own
  annotations.
- `prefix [` enters native copy mode. Neru owns the default `shift+cmd+c`.
- `prefix shift+p` opens a project.

## Hosts

Hosts are stored in the Rex home, not this repository. `rex hosts list` shows
them.

- `knockon` uses `http://knockon:7297`.
- `t2knock-lab` uses `ssh://t2knock@t2knock-lab`. Add it with
  `rex server install --yes --label t2knock-lab ssh://t2knock@t2knock-lab`.

A port forward needs a session. The zsh helper `lab-forward` creates the `lab`
session if it is missing.

## Checks

```bash
stylua --check .
rex config check
rex keymap
rex config reload
```

`rex config check` loads the file without applying it. `rex config reload`
applies it to the running server on this machine. For a binding change, compare
the key and action columns of `rex keymap` before and after.
