-- Rex configuration.
-- Apply a change with: rex config reload
-- Check a change first with: rex config check
--
-- Sections: custom actions, modes, panes, tabs, sessions, search, config.

-- Rex names the three levels sessions, windows, and blocks.
-- Ghostty names them tabs and splits. This file keeps the Ghostty keys.
-- A second Ctrl-a returns one Ctrl-a to the terminal, for readline.

local PREFIX = "ctrl+a"

-- Custom actions -------------------------------------------------------------

-- Select a session by its position, as herdr selects a workspace.
rex.action{
  name = "session_goto",
  title = "Go to Session by Position",
  description = "Select a session by its position in the session list.",
  category = "Sessions",
  keywords = "workspace jump switch",
  args = { index = "integer" },
  run = function(_, args)
    local result, err = rex.call("session.list")
    if result == nil then error(err or "session.list failed", 0) end

    local session = result.sessions[args.index]
    if session == nil then
      error("no session at position " .. args.index, 0)
    end

    rex.client.queue("session.select", { session_id = session.session_id })
    return { session_id = session.session_id, label = session.label }
  end,
}

-- Rename the current session. Without a name, open the rename field in the
-- app. With a name, set it at once from the CLI or the command palette.
rex.action{
  name = "session_rename",
  title = "Rename Session",
  description = "Rename the current session, or open the rename field when no name is given.",
  category = "Sessions",
  keywords = "rename name label title",
  args = { label = "string?" },
  run = function(ctx, args)
    if args.label == nil or args.label == "" then
      rex.client.queue("session.rename")
      return
    end

    local _, err = rex.call("session.set_label", {
      session_id = ctx.session_id,
      label = args.label,
    })
    if err ~= nil then error(err, 0) end

    return { label = args.label }
  end,
}

-- Modes ----------------------------------------------------------------------

-- Resize mode, entered with prefix r as in Ghostty. An exclusive mode keeps
-- ordinary keys from reaching the terminal while it is active.
rex.mode("resize", { exclusive = true })

rex.bind(PREFIX .. ">r", "client.mode.enter", { name = "resize" })

rex.bind("resize/left", "pane.resize", { direction = "left", amount = 10 })
rex.bind("resize/right", "pane.resize", { direction = "right", amount = 10 })
rex.bind("resize/up", "pane.resize", { direction = "up", amount = 10 })
rex.bind("resize/down", "pane.resize", { direction = "down", amount = 10 })

rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/q", "client.mode.exit")

-- Panes ----------------------------------------------------------------------

rex.bind(PREFIX .. ">-", "pane.split", { direction = "right" })
rex.bind(PREFIX .. ">shift+-", "pane.split", { direction = "down" })

-- Move between panes with the vim keys, as in Ghostty.
rex.bind(PREFIX .. ">h", "pane.focus.left")
rex.bind(PREFIX .. ">j", "pane.focus.down")
rex.bind(PREFIX .. ">k", "pane.focus.up")
rex.bind(PREFIX .. ">l", "pane.focus.right")

-- Cycle panes, the way herdr cycles agent panels.
rex.bind(PREFIX .. ">left", "pane.focus_previous")
rex.bind(PREFIX .. ">right", "pane.focus_next")

rex.bind(PREFIX .. ">f", "pane.zoom")
rex.bind(PREFIX .. ">x", "pane.close")
rex.bind(PREFIX .. ">=", "pane.balance")

-- Copy mode ------------------------------------------------------------------

-- Rex has no vi copy mode yet. This opens a read-only snapshot of the pane in
-- nvim, where the vi motions, search, and yank already work. Any yank copies
-- and closes, as in tmux. Press q to close without copying. Output that
-- arrives while nvim is open is not in the snapshot. A full-screen program has
-- no scrollback, so only its current screen is copied. On a remote server,
-- yank stays on that machine.

local TERMINAL_CREATOR = "com.superlogical.terminal"
local TERMINAL_FLAVOR = TERMINAL_CREATOR .. ".shell"
local COPY_PAGER = "nvim"
local COPY_MARGIN = 0.015
local COPY_MIN_SIZE = 0.4
local COPY_DEFAULT_BOUNDS = { x = 0.04, y = 0.03, w = 0.92, h = 0.94 }

---Read the screen and all scrollback, in as many parts as the server needs.
---@param block_id string
---@return string? content
---@return string? err
local function capture_scrollback(block_id)
  local part, err = rex.block.call(TERMINAL_CREATOR, "format", {
    block_id = block_id,
    format = "text",
    trim = true,
    unwrap = true,
    max_bytes = 900000,
  })
  if part == nil then return nil, err end

  local content = part.content
  local id = part.id
  while id ~= nil do
    local next_part, read_err = rex.block.call(TERMINAL_CREATOR, "blob_read", {
      block_id = block_id,
      id = id,
      offset = #content,
      max_bytes = 900000,
    })
    if next_part == nil then return nil, read_err end
    -- An empty part with no end marker would loop forever.
    if next_part.data == "" then break end
    content = content .. next_part.data
    if next_part.eof then break end
  end

  return content
end

---Create a private file for the snapshot. Use mktemp when the host has it, so
---the name is not predictable on a shared machine.
---@param content string
---@return string? path
---@return string? err
local function write_snapshot(content)
  local dir = os.getenv("TMPDIR") or "/tmp/"
  if dir:sub(-1) ~= "/" then dir = dir .. "/" end

  local result = rex.exec({ "mktemp", dir .. "rex-copy-XXXXXX" })
  local path
  if result ~= nil and result.ok then
    path = result.stdout:gsub("%s+$", "")
  else
    path = os.tmpname()
  end

  local file, err = io.open(path, "w")
  if file == nil then
    os.remove(path)
    return nil, err
  end

  file:write(content)
  file:close()
  return path
end

---Find a block's rectangle in its window, as [x, y, w, h] fractions.
---@param block_id string
---@return number[]? rect
---@return string? window_id
local function block_rect(block_id)
  local view = rex.session.view{}
  if view == nil then return nil end

  local function find(node)
    if node == nil then return nil end
    if node.block_id == block_id then return node.rect end
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
        local hidden = layer.state == "minimized" or (layer.kind == "tiled" and window.zoomed_block_id ~= nil)
        if hidden then return nil, window.window_id end
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

rex.action{
  name = "copy_mode",
  title = "Copy Mode (in nvim)",
  description = "Open the pane's screen and scrollback in nvim, read-only, for vi-style navigation and yank.",
  category = "Panes",
  keywords = "copy mode scrollback select yank vi search",
  args = { block_id = "string?" },
  run = function(ctx, args)
    local block_id = args.block_id or ctx.block_id
    if block_id == nil then error("copy_mode needs a terminal pane", 0) end

    local content, capture_err = capture_scrollback(block_id)
    if content == nil then error(capture_err, 0) end

    local path, file_err = write_snapshot(content)
    if path == nil then error(file_err, 0) end

    local rect, window_id = block_rect(block_id)
    local bounds = rect ~= nil and fit_bounds(rect) or COPY_DEFAULT_BOUNDS

    local opened, open_err = rex.session.new_layer{
      window_id = window_id,
      bounds = bounds,
      focus = true,
      layout = rex.layout.block{
        flavor = TERMINAL_FLAVOR,
        label = "copy mode",
        options = {
          -- -u NONE keeps startup fast and predictable. The options below add
          -- the few things the pager needs from a normal configuration.
          command = {
            COPY_PAGER,
            "-R",
            "-u", "NONE",
            "-i", "NONE",
            "-n",
            "-c", "set clipboard=unnamedplus nomodifiable readonly nonumber ruler",
            "-c", "autocmd TextYankPost * call timer_start(0, {-> execute('qa!')})",
            "-c", "autocmd VimLeavePre * silent! call delete(expand('%:p'))",
            "-c", "nnoremap <silent> <nowait> q :qa!<CR>",
            "-c", "xnoremap <silent> <CR> y",
            "-c", "normal! Gzb",
            path,
          },
        },
      },
    }
    if opened == nil then
      os.remove(path)
      error(open_err, 0)
    end

    return { block_id = opened.block_ids[1], bytes = #content, path = path }
  end,
}

-- Scroll mode ----------------------------------------------------------------

-- Move through output without leaving the terminal. In a shell, j and k scroll
-- one page, and n and p jump between prompts. In a full-screen program, every
-- key sends Page Up or Page Down. Enter the mode with prefix u.

local ALT_SCREEN = { [47] = true, [1047] = true, [1049] = true }

---@param block_id string
---@return boolean
local function on_alternate_screen(block_id)
  local modes = rex.block.call(TERMINAL_CREATOR, "modes", { block_id = block_id })
  if modes == nil then return false end

  for _, mode in ipairs(modes.modes or {}) do
    if ALT_SCREEN[mode.number] and mode.set then return true end
  end
  return false
end

rex.action{
  name = "scroll_step",
  title = "Scroll Step",
  description = "Scroll one page, or jump between prompts when the unit is prompt.",
  category = "Panes",
  keywords = "scroll prompt page up down history",
  args = { direction = "string", unit = "string?" },
  run = function(ctx, args)
    local block_id = ctx.block_id
    if block_id == nil then error("scroll_step needs a terminal pane", 0) end

    local up = args.direction == "up"
    if on_alternate_screen(block_id) then
      local _, err = rex.block.call(TERMINAL_CREATOR, "write", {
        block_id = block_id,
        data = up and "\27[5~" or "\27[6~",
      })
      if err ~= nil then error(err, 0) end
    elseif args.unit == "prompt" then
      rex.client.queue(up and "client.prompt.previous" or "client.prompt.next")
    else
      rex.client.queue(up and "client.scroll.page_up" or "client.scroll.page_down")
    end
  end,
}

rex.mode("scroll", { exclusive = true })
rex.bind(PREFIX .. ">u", "client.mode.enter", { name = "scroll" })

rex.bind("scroll/k", "scroll_step", { direction = "up" })
rex.bind("scroll/up", "scroll_step", { direction = "up" })
rex.bind("scroll/ctrl+u", "scroll_step", { direction = "up" })
rex.bind("scroll/j", "scroll_step", { direction = "down" })
rex.bind("scroll/down", "scroll_step", { direction = "down" })
rex.bind("scroll/ctrl+d", "scroll_step", { direction = "down" })

rex.bind("scroll/p", "scroll_step", { direction = "up", unit = "prompt" })
rex.bind("scroll/n", "scroll_step", { direction = "down", unit = "prompt" })

rex.bind("scroll/q", "client.mode.exit")
rex.bind("scroll/escape", "client.mode.exit")
rex.bind("scroll/enter", "client.mode.exit")

-- Tabs -----------------------------------------------------------------------

rex.bind(PREFIX .. ">c", "client.tab.new")
rex.bind(PREFIX .. ">n", "client.tab.next")
rex.bind(PREFIX .. ">p", "client.tab.previous")
rex.bind(PREFIX .. ">t", "client.tab.rename")

for index = 1, 9 do
  rex.bind(PREFIX .. ">" .. index, "client.tab.goto", { index = index })
end

-- Sessions -------------------------------------------------------------------

rex.bind(PREFIX .. ">shift+n", "session.new")
rex.bind(PREFIX .. ">s", "session.switch")
rex.bind(PREFIX .. ">,", "session_rename")
rex.bind(PREFIX .. ">up", "session.previous")
rex.bind(PREFIX .. ">down", "session.next")

for index = 1, 9 do
  rex.bind(PREFIX .. ">shift+" .. index, "session_goto", { index = index })
end

-- Search and configuration ---------------------------------------------------

-- Copy mode, as prefix [ in tmux. Rex has no built-in copy mode yet, so this
-- opens a read-only snapshot in nvim.
rex.bind(PREFIX .. ">[", "copy_mode")

-- Search the scrollback.
rex.bind(PREFIX .. ">/", "client.find.open")

rex.bind(PREFIX .. ">shift+r", "client.config.reload")

-- A second Ctrl-a reaches readline.
rex.bind(PREFIX .. ">ctrl+a", "pane.send_key", { key = "ctrl+a" })
