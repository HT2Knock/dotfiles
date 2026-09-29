// Removes the project AGENTS.md instructions of the repositories listed below
// from the model system context. The global ~/.config/opencode/AGENTS.md and
// all other repositories keep their instructions.
//
// OpenCode V2 renders instructions as one system part:
//
//   Instructions from: <absolute path>
//   <content>
//
// The plugin matches each block by its file path and drops the blocked ones.
// Add or remove repository paths in BLOCKED_REPOS.

const MARKER = "Instructions from: ";

const BLOCKED_REPOS = ["/Users/ht2knock/Documents/adam/pim"];

function is_blocked(file_path) {
  return BLOCKED_REPOS.some(
    (repo) =>
      file_path === `${repo}/AGENTS.md` || file_path.startsWith(`${repo}/`),
  );
}

// Returns the text with every instruction block for a blocked repository removed.
// The text before the first block and every non-blocked block stay in order.
function strip_blocked(text) {
  const starts = [];
  let at = text.indexOf(MARKER);
  while (at !== -1) {
    starts.push(at);
    at = text.indexOf(MARKER, at + MARKER.length);
  }
  if (starts.length === 0) return text;

  let result = text.slice(0, starts[0]);
  for (let i = 0; i < starts.length; i += 1) {
    const start = starts[i];
    const end = i + 1 < starts.length ? starts[i + 1] : text.length;
    const block = text.slice(start, end);
    const line_end = block.indexOf("\n");
    const file_path = block.slice(
      MARKER.length,
      line_end === -1 ? undefined : line_end,
    );
    if (!is_blocked(file_path)) result += block;
  }
  return result;
}

export default {
  id: "personal.block-repo-instructions",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      try {
        for (let i = 0; i < event.system.length; i += 1) {
          const part = event.system[i];
          if (typeof part?.text !== "string" || !part.text.includes(MARKER))
            continue;
          const text = strip_blocked(part.text);
          if (text !== part.text) event.system[i] = { ...part, text };
        }
      } catch (error) {
        console.error("block-repo-instructions failed", error);
      }
    });
  },
};
