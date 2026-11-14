-- Global key bindings.
--
-- Rex names the three levels sessions, windows, and blocks. Ghostty names them
-- tabs and splits. This file keeps the Ghostty keys. A second Ctrl-a returns
-- one Ctrl-a to the terminal, for readline.
--
-- A mode that owns an action keeps its own keys in that action's module, such
-- as actions/scroll.lua. This file holds the key that enters each mode.

local PREFIX = 'ctrl+a'

-- Resize mode ----------------------------------------------------------------

-- Entered with prefix r as in Ghostty. An exclusive mode keeps ordinary keys
-- from reaching the terminal while it is active.
rex.mode('resize', { exclusive = true })

rex.bind(PREFIX .. '>r', 'client.mode.enter', { name = 'resize' })

rex.bind('resize/left', 'pane.resize', { direction = 'left', amount = 10 })
rex.bind('resize/right', 'pane.resize', { direction = 'right', amount = 10 })
rex.bind('resize/up', 'pane.resize', { direction = 'up', amount = 10 })
rex.bind('resize/down', 'pane.resize', { direction = 'down', amount = 10 })

rex.bind('resize/escape', 'client.mode.exit')
rex.bind('resize/enter', 'client.mode.exit')
rex.bind('resize/q', 'client.mode.exit')

-- Panes ----------------------------------------------------------------------

rex.bind(PREFIX .. '>-', 'pane.split', { direction = 'right' })
rex.bind(PREFIX .. '>shift+-', 'pane.split', { direction = 'down' })

-- Move between panes with the vim keys, as in Ghostty.
rex.bind(PREFIX .. '>h', 'pane.focus.left')
rex.bind(PREFIX .. '>j', 'pane.focus.down')
rex.bind(PREFIX .. '>k', 'pane.focus.up')
rex.bind(PREFIX .. '>l', 'pane.focus.right')

-- Cycle panes, the way herdr cycles agent panels.
rex.bind(PREFIX .. '>left', 'pane.focus_previous')
rex.bind(PREFIX .. '>right', 'pane.focus_next')

rex.bind(PREFIX .. '>f', 'pane.zoom')
rex.bind(PREFIX .. '>x', 'pane.close')
rex.bind(PREFIX .. '>=', 'pane.balance')

-- Modes ----------------------------------------------------------------------

rex.bind(PREFIX .. '>u', 'client.mode.enter', { name = 'scroll' })

-- Tabs -----------------------------------------------------------------------

rex.bind(PREFIX .. '>c', 'client.tab.new')
rex.bind(PREFIX .. '>n', 'client.tab.next')
rex.bind(PREFIX .. '>p', 'client.tab.previous')
rex.bind(PREFIX .. '>t', 'client.tab.rename')

for index = 1, 9 do
  rex.bind(PREFIX .. '>' .. index, 'client.tab.goto', { index = index })
end

-- Sessions -------------------------------------------------------------------

rex.bind(PREFIX .. '>shift+n', 'session.new')
rex.bind(PREFIX .. '>s', 'session.switch')

-- The switcher's list keys, ctrl+1, ctrl+2 and ctrl+3, are taken by AeroSpace.
-- Open Activity on its own key instead of switching lists inside the switcher.
rex.bind(PREFIX .. '>a', 'pane.view_activity')
rex.bind(PREFIX .. '>,', 'session_rename')
rex.bind(PREFIX .. '>up', 'session.previous')
rex.bind(PREFIX .. '>down', 'session.next')

for index = 1, 9 do
  rex.bind(PREFIX .. '>shift+' .. index, 'session_goto', { index = index })
end

-- Search and configuration ---------------------------------------------------

-- Copy mode, as prefix [ in tmux. Rex has no built-in copy mode yet, so this
-- opens a read-only snapshot in nvim. See actions/copy_mode.lua.
rex.bind(PREFIX .. '>[', 'copy_mode')

-- Search the scrollback.
rex.bind(PREFIX .. '>/', 'client.find.open')

rex.bind(PREFIX .. '>shift+r', 'client.config.reload')

-- A second Ctrl-a reaches readline.
rex.bind(PREFIX .. '>ctrl+a', 'pane.send_key', { key = 'ctrl+a' })
