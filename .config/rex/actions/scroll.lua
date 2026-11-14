-- Scroll mode.
--
-- Move through output without leaving the terminal. In a shell, j and k scroll
-- one page, and n and p jump between prompts. In a full-screen program, every
-- key sends Page Up or Page Down. Enter the mode with prefix u, in keys.lua.

---@type 'com.superlogical.terminal'
local TERMINAL_CREATOR = 'com.superlogical.terminal'

local ALT_SCREEN = { [47] = true, [1047] = true, [1049] = true }

---@param block_id string
---@return boolean
local function on_alternate_screen(block_id)
  local modes = rex.block.call(TERMINAL_CREATOR, 'modes', { block_id = block_id })
  if modes == nil then
    return false
  end

  for _, mode in ipairs(modes.modes or {}) do
    if ALT_SCREEN[mode.number] and mode.set then
      return true
    end
  end
  return false
end

rex.action {
  name = 'scroll_step',
  title = 'Scroll Step',
  description = 'Scroll one page, or jump between prompts when the unit is prompt.',
  category = 'Panes',
  keywords = 'scroll prompt page up down history',
  args = { direction = 'string', unit = 'string?' },
  run = function(ctx, args)
    local block_id = ctx.block_id
    if block_id == nil then
      error('scroll_step needs a terminal pane', 0)
    end

    local up = args.direction == 'up'
    if on_alternate_screen(block_id) then
      local _, err = rex.block.call(TERMINAL_CREATOR, 'write', {
        block_id = block_id,
        data = up and '\27[5~' or '\27[6~',
      })
      if err ~= nil then
        error(err, 0)
      end
    elseif args.unit == 'prompt' then
      rex.client.queue(up and 'client.prompt.previous' or 'client.prompt.next')
    else
      rex.client.queue(up and 'client.scroll.page_up' or 'client.scroll.page_down')
    end
  end,
}

rex.mode('scroll', { exclusive = true })

rex.bind('scroll/k', 'scroll_step', { direction = 'up' })
rex.bind('scroll/up', 'scroll_step', { direction = 'up' })
rex.bind('scroll/ctrl+u', 'scroll_step', { direction = 'up' })
rex.bind('scroll/j', 'scroll_step', { direction = 'down' })
rex.bind('scroll/down', 'scroll_step', { direction = 'down' })
rex.bind('scroll/ctrl+d', 'scroll_step', { direction = 'down' })

rex.bind('scroll/p', 'scroll_step', { direction = 'up', unit = 'prompt' })
rex.bind('scroll/n', 'scroll_step', { direction = 'down', unit = 'prompt' })

rex.bind('scroll/q', 'client.mode.exit')
rex.bind('scroll/escape', 'client.mode.exit')
rex.bind('scroll/enter', 'client.mode.exit')
