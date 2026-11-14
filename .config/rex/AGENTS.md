# Rex configuration

`init.lua` is the entry point. It loads `keys.lua` and the modules in `actions/`.

- `keys.lua` holds the prefix, the key that enters each mode, and every global binding.
- A module in `actions/` holds one custom action. A module that declares a mode also holds that mode's own keys.
- `types/rex.lua` is a hand-written LuaCATS file for lua-language-server. The `lazydev` plugin in `.config/nvim` loads it. Delete it when Rex ships its own annotations.
- Copy mode is temporary until Rex ships a native one. Delete `actions/copy_mode.lua` and its binding at that point.

## Checks

```bash
stylua --check .
rex config check
rex keymap
rex config reload
```

`rex config check` loads the file without applying it. `rex config reload` applies it to the running server, which must be on this machine. For a binding change, compare the key and action columns of `rex keymap` before and after.
