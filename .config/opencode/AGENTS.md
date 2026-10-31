# How to work and collaborate effectively

- Use Simplified Technical English (STE) for all English text, in responses and in code.
- Do not use metaphors, idioms, or dramatic jargon, for example "blast radius" or "foot gun".
- Write self-explanatory code. Add a comment only when the code cannot show the reason.
- For long research or analysis, write a script instead of many one-off commands.
- Treat questions about the codebase as read-only unless the user asks for changes.
- Do not assume. Surface tradeoffs instead of hiding uncertainty.
- Prove work on the real artifact before you call it done: run the feature, read the value, inspect the diff. Do not trust a proxy, a self-report, or "it compiles". The `diagnosing-bugs` skill owns the feedback loop.
- Do reversible work without blocking on the human: make the reasonable call, present the result, and let the human correct it. Ask only before an irreversible action.
- When I correct the same mistake a second time, encode the fix at the highest level that works: architecture, then types, then a lint or check whose error names the fix, then a test. Write the rule down last. Prove the check fails on the real past mistake.
- Keep this file small. Put app-specific rules in that app's AGENTS.md, and move a large rule set into a skill.
