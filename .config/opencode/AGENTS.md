# Working rules

- Write all English in Simplified Technical English (STE), in responses and
  code.
- Do not use metaphors, idioms, or dramatic words such as "blast radius" or
  "foot gun".
- Write self-explanatory code. Add a comment only when the code cannot show the
  reason.
- Write a script for long research or analysis instead of many one-off commands.
- Treat questions about the codebase as read-only unless the user asks for
  changes.
- State assumptions and tradeoffs. Ask when the answer changes the work.
- Prove work on the real artifact: run the feature, read the value, inspect the
  diff. A passing compile is not proof. The `diagnosing-bugs` skill owns the
  feedback loop.
- Keep long-running work visible in Rex:
  `rex run --focus=false --json -- <command>`, then read it with
  `rex capture -b <block_id>`. Use `nohup` or `&` only when the work must
  outlive the session.
- Do reversible work without waiting for the human. Ask before an irreversible
  action.
- When the user corrects the same mistake twice, fix the cause at the highest
  level: architecture, types, a check whose error names the fix, then a test.
  Write the rule down last. Prove the check fails on the old mistake.
- Keep this file small. Put app rules in the app's `AGENTS.md`; move a large
  rule set into a skill.
