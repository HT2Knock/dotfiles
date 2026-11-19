local PROJECT_ICON = 'folder'
local MAX_ITEMS = 2000
local TOOL_PATH = '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin'

local function project_items(stdout)
  local items = {}
  for line in stdout:gmatch '[^\n]+' do
    local path = line:match '^%s*%S+%s+(.+)$'
    if path ~= nil and path ~= '' then
      items[#items + 1] = {
        id = path,
        title = path:match '([^/]+)/*$' or path,
        subtitle = path,
        icon = PROJECT_ICON,
      }
      if #items == MAX_ITEMS then
        break
      end
    end
  end
  return items
end

rex.action {
  name = 'project_open',
  title = 'Open Project…',
  description = 'Pick a directory from zoxide history and open or switch to its session.',
  category = 'Sessions',
  keywords = 'project zoxide directory workspace open',
  run = function()
    if rex.ui == nil then
      error('project_open needs Rex server preview.21 or newer. Restart Rex to update the server.', 0)
    end

    local result = rex.exec({ 'zoxide', 'query', '-ls' }, { env = { PATH = TOOL_PATH }, timeout = 5 })
    if result == nil or not result.ok then
      error('zoxide query failed: ' .. (result and result.stderr or 'not found'), 0)
    end

    local items = project_items(result.stdout)
    if #items == 0 then
      error('zoxide has no directories', 0)
    end

    local dir = rex.ui.pick {
      title = 'Open project',
      placeholder = 'Filter projects',
      items = items,
    }
    if dir == nil then
      return
    end

    local name = dir:match '([^/]+)/*$' or dir
    local listed, list_err = rex.call 'session.list'
    if listed == nil then
      error(list_err or 'session.list failed', 0)
    end

    for _, session in ipairs(listed.sessions or {}) do
      if session.label == name then
        rex.client.queue('session.select', { session_id = session.session_id })
        return { session_id = session.session_id, label = name }
      end
    end

    local created, create_err = rex.call('session.create', {
      label = name,
      initial_windows = {
        {
          layout = rex.layout.block {
            flavor = 'com.superlogical.terminal.shell',
            options = { cwd = dir },
            label = name,
          },
          window_label = name,
        },
      },
    })
    if created == nil then
      error(create_err or 'session.create failed', 0)
    end

    rex.client.queue('session.select', { session_id = created.session_id })
    return { session_id = created.session_id, label = name }
  end,
}
