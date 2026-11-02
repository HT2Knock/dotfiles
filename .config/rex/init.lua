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
rex.bind(PREFIX .. ">up", "session.previous")
rex.bind(PREFIX .. ">down", "session.next")

for index = 1, 9 do
  rex.bind(PREFIX .. ">shift+" .. index, "session_goto", { index = index })
end

-- Search and configuration ---------------------------------------------------

-- Search the scrollback. Ghostty scroll mode has no direct Rex equivalent.
rex.bind(PREFIX .. ">[", "client.find.open")

rex.bind(PREFIX .. ">shift+r", "client.config.reload")

-- A second Ctrl-a reaches readline.
rex.bind(PREFIX .. ">ctrl+a", "pane.send_key", { key = "ctrl+a" })
