-- Session actions.

-- Select a session by its position, as herdr selects a workspace.
rex.action {
  name = 'session_goto',
  title = 'Go to Session by Position',
  description = 'Select a session by its position in the session list.',
  category = 'Sessions',
  keywords = 'workspace jump switch',
  args = { index = 'integer' },
  run = function(_, args)
    local result, err = rex.call 'session.list'
    if result == nil then
      error(err or 'session.list failed', 0)
    end

    local sessions = result.sessions or {}
    local session = sessions[args.index]
    if session == nil then
      error('no session at position ' .. tostring(args.index), 0)
    end

    rex.client.queue('session.select', { session_id = session.session_id })
    return { session_id = session.session_id, label = session.label }
  end,
}

-- Rename the current session. Without a name, open the rename field in the
-- app. With a name, set it at once from the CLI or the command palette.
rex.action {
  name = 'session_rename',
  title = 'Rename Session',
  description = 'Rename the current session, or open the rename field when no name is given.',
  category = 'Sessions',
  keywords = 'rename name label title',
  args = { label = 'string?' },
  run = function(ctx, args)
    if args.label == nil or args.label == '' then
      rex.client.queue 'session.rename'
      return
    end

    if ctx.session_id == nil then
      error('session_rename needs a session', 0)
    end

    -- rex.session.set_label fills in the session from the context.
    local _, err = rex.session.set_label { label = args.label }
    if err ~= nil then
      error(err, 0)
    end

    return { label = args.label }
  end,
}
