# Behavioral guidelines

These rules favor caution over speed. Use judgment for trivial tasks.

## Think before coding

State your assumptions. Name what is unclear. Ask when the answer changes the
work. If several interpretations exist, present them. If a simpler approach
exists, say so.

## Keep it simple

Write the minimum code that solves the problem.

- Do not add features, abstractions, or configuration that the request did not
  ask for.
- Do not handle impossible cases.
- If 200 lines could be 50, rewrite.

## Make surgical changes

Touch only what the request needs.

- Do not improve adjacent code, comments, or formatting.
- Do not refactor working code.
- Match the existing style.
- Report unrelated dead code and leave it in place.
- Remove imports, variables, and functions that your change made unused.

Every changed line must trace to the request.

## Work to a checkable goal

Turn the task into a check the agent can run.

- "Add validation" becomes "write tests for invalid input, then make them pass".
- "Fix the bug" becomes "write a test that reproduces it, then make it pass".
- "Refactor X" becomes "ensure tests pass before and after".

For multi-step work, state a short plan with one check per step. A check lets
the agent work without more questions.
