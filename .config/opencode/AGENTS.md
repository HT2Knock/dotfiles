# How to work and collaborate effectively

- Use Simplified Technical English (STE) for all English text, in responses and in code.
- Do not use metaphors, idioms, or dramatic jargon, for example "blast radius" or "foot gun".
- Write self-explanatory code. Add a comment only when the code cannot show the reason.
- For long research or analysis, write a script instead of many one-off commands.
- Treat questions about the codebase as read-only unless the user asks for changes.
- Do not assume. Surface tradeoffs instead of hiding uncertainty.
- Keep this file small. Put app-specific rules in that app's AGENTS.md, and move a large rule set into a skill.

## Package management

- Add or remove packages by editing `packages/repo.txt` and `packages/aur.txt`, then run
  `scripts/install-packages.sh`. Run `scripts/export-packages.sh` to refresh the lists
  from the current system.
- Run package commands one at a time. A second pacman process fails on the database lock.
- Use `paru -Syu` for an upgrade. Never run `paru -Sy` or `pacman -Sy` alone, because a
  partial upgrade breaks an Arch system.
- Set the shell timeout to at least 1800000 ms for `paru` and `makepkg` commands. The
  password dialog and a build take longer than the 120 s default.
- The paru elevation path is `/usr/local/bin/sudo-gui`. Do not change it. Read the
  password dialog before you approve it.
