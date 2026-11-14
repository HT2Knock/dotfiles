-- Copy mode.
--
-- Rex has no vi copy mode yet. This opens a read-only snapshot of the pane in
-- nvim, where the vi motions, search, and yank already work. Any yank copies
-- and closes, as in tmux. Press q to close without copying. Output that
-- arrives while nvim is open is not in the snapshot. A full-screen program has
-- no scrollback, so only its current screen is copied.
--
-- The snapshot must be built where the pane runs, not where this action runs.
-- The app runs init.lua on the local machine even when the focused pane
-- belongs to a remote host, so a temporary path from here does not exist
-- there. The command below asks the host's own rex to capture the pane, and
-- keeps every file in that host's temporary directory.
--
-- The pane's host must have sh, rex, nvim, and base64.
--
-- A yank never uses the clipboard of the machine that runs the pager. Nvim
-- writes the yanked text to a file, and the shell that started it sends the
-- text to the app as an OSC 52 sequence. The app then sets the clipboard of
-- the device in front of you, so this works when the pane is on a remote host.

local TERMINAL_CREATOR = 'com.superlogical.terminal'
local TERMINAL_FLAVOR = TERMINAL_CREATOR .. '.shell'
local COPY_PAGER = 'nvim'
local COPY_MARGIN = 0.015
local COPY_MIN_SIZE = 0.4
local COPY_DEFAULT_BOUNDS = { x = 0.04, y = 0.03, w = 0.92, h = 0.94 }
local DOC_NAME = 'doc'
local HELPER_NAME = 'helper.lua'
local YANK_SUFFIX = '.yank'
local HELPER_END = 'REX_COPY_HELPER'

---Quote a value for the POSIX shell.
---@param value string
---@return string
local function shell_quote(value)
  return "'" .. (value:gsub("'", [['\'']])) .. "'"
end

---Build the nvim script that reports a yank beside the snapshot.
---@return string
local function pager_script()
  return table.concat({
    'vim.o.modifiable = false',
    'vim.o.readonly = true',
    'vim.o.number = false',
    'vim.o.ruler = true',
    '',
    "local yank_path = vim.fn.expand('%:p') .. '" .. YANK_SUFFIX .. "'",
    '',
    'local function on_yank()',
    "  local file = io.open(yank_path, 'wb')",
    '  if file ~= nil then',
    "    file:write(vim.fn.getreg('\"'))",
    '    file:close()',
    '  end',
    '  vim.schedule(function()',
    "    vim.cmd('qa!')",
    '  end)',
    'end',
    '',
    "vim.api.nvim_create_autocmd('TextYankPost', { callback = on_yank })",
    "vim.keymap.set('n', 'q', ':qa!<CR>', { silent = true, nowait = true })",
    "vim.keymap.set('x', '<CR>', 'y', { silent = true })",
    "vim.cmd('normal! Gzb')",
  }, '\n') .. '\n'
end

---Build the command that captures, pages, and copies on the pane's host.
---@param session_id string
---@param block_id string
---@return string
local function pager_command(session_id, block_id)
  return table.concat({
    'set -e',
    'd=$(mktemp -d "${TMPDIR:-/tmp}/rex-copy-XXXXXX")',
    [[trap 'rm -rf "$d"' EXIT]],
    -- Run from the temporary directory, so no path needs quoting for nvim.
    'cd "$d"',
    [[rex="${REX_BIN_DIR:+$REX_BIN_DIR/}rex"]],
    'if ! "$rex" capture -s ' .. shell_quote(session_id) .. ' -b ' .. shell_quote(block_id) .. ' --trim --unwrap > ' .. DOC_NAME .. ' 2> err; then',
    '  mv err ' .. DOC_NAME,
    'fi',
    'cat > ' .. HELPER_NAME .. " <<'" .. HELPER_END .. "'",
    pager_script() .. HELPER_END,
    COPY_PAGER .. ' -R -u NONE -i NONE -n -c "luafile ' .. HELPER_NAME .. '" ' .. DOC_NAME,
    'if [ -s ' .. DOC_NAME .. YANK_SUFFIX .. ' ]; then',
    "  printf '\\033]52;c;%s\\a' \"$(base64 < " .. DOC_NAME .. YANK_SUFFIX .. " | tr -d '\\n')\"",
    'fi',
  }, '\n')
end

---Find a block's rectangle in its window, as [x, y, w, h] fractions.
---@param session_id string
---@param block_id string
---@return number[]? rect
---@return string? window_id
local function block_rect(session_id, block_id)
  local view = rex.session.view { session_id = session_id }
  if view == nil then
    return nil
  end

  local function find(node)
    if node == nil then
      return nil
    end
    if node.block_id == block_id then
      return node.rect
    end
    if node.split ~= nil then
      return find(node.split.before) or find(node.split.after)
    end
    return nil
  end

  for _, window in ipairs(view.windows or {}) do
    if window.zoomed_block_id == block_id then
      return { 0, 0, 1, 1 }, window.window_id
    end

    for _, layer in ipairs(window.layers or {}) do
      local rect = find(layer.layout)
      if rect ~= nil then
        local hidden = layer.state == 'minimized' or (layer.kind == 'tiled' and window.zoomed_block_id ~= nil)
        if hidden then
          return nil, window.window_id
        end
        return rect, window.window_id
      end
    end
  end

  return nil
end

---Inset a pane rectangle and keep the result large enough to read.
---@param rect number[]
---@return { x: number, y: number, w: number, h: number }
local function fit_bounds(rect)
  local function axis(pos, len)
    local size = math.max(len - 2 * COPY_MARGIN, COPY_MIN_SIZE)
    local start = math.max(0, math.min(pos + (len - size) / 2, 1 - size))
    return start, math.min(size, 1 - start)
  end

  local x, w = axis(rect[1], rect[3])
  local y, h = axis(rect[2], rect[4])
  return { x = x, y = y, w = w, h = h }
end

rex.action {
  name = 'copy_mode',
  title = 'Copy Mode (in nvim)',
  description = "Open the pane's screen and scrollback in nvim, read-only, for vi-style navigation and yank.",
  category = 'Panes',
  keywords = 'copy mode scrollback select yank vi search',
  args = { block_id = 'string?' },
  run = function(ctx, args)
    local block_id = args.block_id or ctx.block_id
    if block_id == nil then
      error('copy_mode needs a terminal pane', 0)
    end

    local session_id = ctx.session_id
    if session_id == nil then
      error('copy_mode needs a session', 0)
    end

    local rect, window_id = block_rect(session_id, block_id)
    local bounds = rect ~= nil and fit_bounds(rect) or COPY_DEFAULT_BOUNDS

    local opened, open_err = rex.session.new_layer {
      window_id = window_id,
      bounds = bounds,
      focus = true,
      layout = rex.layout.block {
        flavor = TERMINAL_FLAVOR,
        label = 'copy mode',
        options = {
          command = { 'sh', '-c', pager_command(session_id, block_id) },
        },
      },
    }
    if opened == nil then
      error(open_err or 'session.new_layer failed', 0)
    end

    local new_block = opened.block_ids and opened.block_ids[1]
    if new_block == nil then
      error('session.new_layer returned no block', 0)
    end

    return { block_id = new_block }
  end,
}
