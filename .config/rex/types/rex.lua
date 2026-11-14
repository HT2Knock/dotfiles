---Rex Lua API definitions for lua-language-server.
---
---Written by hand from https://www.superlogical.com/rex/docs/reference/lua.md.
---Rex has an open request to ship this file: feedback 1562770773746126858.
---Remove this file when Rex ships its own LuaCATS annotations.
---@meta

---@class rex
rex = {}

---@class rex.Context
---@field session_id? string
---@field block_id? string
---@field client_id? string
---@field origin? "key"|"palette"|"cli"|"api"|"script"|"timer"
---@field server? string

---@class rex.KeyEvent
---@field keybinding string
---@field prefix? string[]

---@class rex.Action
---@field name string
---@field title string
---@field run fun(ctx: rex.Context, args: table): any
---@field description? string
---@field category? string
---@field keywords? string
---@field args? table<string, string>|table
---@field repeats? boolean

---@class rex.Binding
---@field key string
---@field mode? string
---@field action? string
---@field fn? function
---@field args? table
---@field source string

---@class rex.BindingFilter
---@field key? string
---@field mode? string
---@field action? string

---@class rex.Mode
---@field name string
---@field exclusive boolean
---@field source string

---@param key string
---@param action string
---@param args? table
---@overload fun(key: string, fn: fun(ctx: rex.Context, ev: rex.KeyEvent): boolean?)
function rex.bind(key, action, args) end

---@param key string|{ mode: string }|rex.Binding
---@param target? string|function
---@return integer
function rex.unbind(key, target) end

---@param name string
---@param opts? { exclusive?: boolean }
function rex.mode(name, opts) end

---@param filter? rex.BindingFilter
---@return rex.Binding[]
function rex.bindings(filter) end

---@return rex.Mode[]
function rex.modes() end

---@param action rex.Action
function rex.action(action) end

---@param name string
---@param args? table
---@return any, string?
function rex.invoke(name, args) end

---@class rex.Client
rex.client = {}

---@param name string
---@param args? table
function rex.client.queue(name, args) end

---@class rex.Session
rex.session = {}

---@param args? table
---@return table?, string?
function rex.session.view(args) end

---@param args? table
---@return table?, string?
function rex.session.list_blocks(args) end

---@param args? table
---@return table?, string?
function rex.session.list_clients(args) end

---@param args? table
---@return table?, string?
function rex.session.describe_block(args) end

---@param args? table
---@return table?, string?
function rex.session.new_window(args) end

---@param args? table
---@return table?, string?
function rex.session.new_split(args) end

---@param args? table
---@return table?, string?
function rex.session.new_block(args) end

---@param args? table
---@return table?, string?
function rex.session.new_layer(args) end

---@param args? table
---@return table?, string?
function rex.session.close_window(args) end

---@param args? table
---@return table?, string?
function rex.session.close_layer(args) end

---@param args? table
---@return table?, string?
function rex.session.move_block(args) end

---@param args? table
---@return table?, string?
function rex.session.swap_blocks(args) end

---@param args? table
---@return table?, string?
function rex.session.detach_block(args) end

---@param args? table
---@return table?, string?
function rex.session.float_block(args) end

---@param args? table
---@return table?, string?
function rex.session.zoom_block(args) end

---@param args? table
---@return table?, string?
function rex.session.resize_pane(args) end

---@param args? table
---@return table?, string?
function rex.session.resize_layer(args) end

---@param args? table
---@return table?, string?
function rex.session.raise_layer(args) end

---@param args? table
---@return table?, string?
function rex.session.lower_layer(args) end

---@param args? table
---@return table?, string?
function rex.session.move_window(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_block(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_window(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_direction(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_next_pane(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_previous_pane(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_next_window(args) end

---@param args? table
---@return table?, string?
function rex.session.focus_previous_window(args) end

---@param args? table
---@return table?, string?
function rex.session.set_label(args) end

---@param args? table
---@return table?, string?
function rex.session.set_window_label(args) end

---@param args? table
---@return table?, string?
function rex.session.set_block_label(args) end

---@param args? table
---@return table?, string?
function rex.session.attach(args) end

---@param args? table
---@return table?, string?
function rex.session.detach(args) end

---@param args? table
---@return table?, string?
function rex.session.help(args) end

---@param method string
---@param args? table
---@return table?, string?
function rex.call(method, args) end

---@class rex.Block
rex.block = {}

---@class rex.TerminalMode
---@field ansi? boolean
---@field default? boolean
---@field name string
---@field number integer
---@field set boolean

---@class rex.TerminalModes
---@field modes? rex.TerminalMode[]
---@field screen 'primary'|'alternate'|string

---@param creator string
---@param method string
---@param args? table
---@return table?, string?
---@overload fun(creator: 'com.superlogical.terminal', method: 'modes', args?: { block_id?: string, session_id?: string }): rex.TerminalModes?, string?
function rex.block.call(creator, method, args) end

---@class rex.Layout

---@class rex.TerminalOptions
---@field command? string[]
---@field shell? string
---@field cwd? string
---@field initial_input? string
---@field exit? { on_completion?: boolean }

---@class rex.LayoutLib
rex.layout = {}

---@param opts { flavor: string, options?: rex.TerminalOptions }
---@return rex.Layout
function rex.layout.block(opts) end

---@param ratio number
---@param a rex.Layout
---@param b rex.Layout
---@return rex.Layout
function rex.layout.horizontal(ratio, a, b) end

---@param ratio number
---@param a rex.Layout
---@param b rex.Layout
---@return rex.Layout
function rex.layout.vertical(ratio, a, b) end

---@param event string
---@param fn fun(ctx: rex.Context, ev: table)
function rex.on(event, fn) end

---@param event string
---@param filter? table|fun(ev: table, ctx: rex.Context): boolean
---@param timeout? number
---@return table?, string?
function rex.wait(event, filter, timeout) end

---@param seconds number
function rex.sleep(seconds) end

---@param code? integer
function rex.stop(code) end

---@class rex.Host
---@field label string
---@field endpoints string[]
---@field endpoint? string
---@field id? string
---@field icon? string

---@param host rex.Host
function rex.host(host) end

---@return string[]
function rex.servers() end

---@class rex.ServerRef
---@field session rex.Session
---@field block rex.Block
---@field call fun(method: string, args?: table): table?, string?

---@param label string
---@return rex.ServerRef
function rex.server(label) end

---@class rex.ExecOptions
---@field cwd? string
---@field env? table<string, string|false>
---@field clear_env? boolean
---@field stdin? string|true
---@field timeout? number
---@field stdout? false|fun(chunk: string)
---@field stderr? false|fun(chunk: string)
---@field text? boolean
---@field detach? boolean

---@class rex.ExecResult
---@field code integer
---@field signal? string
---@field stdout string
---@field stderr string
---@field timed_out boolean
---@field ok boolean

---@class rex.Process
local process = {}

---@param seconds? number
---@return rex.ExecResult?, string?
function process:wait(seconds) end

---@param data string
---@return boolean?, string?
function process:write(data) end

function process:close_stdin() end

---@param signal? string|integer
function process:kill(signal) end

---@return boolean
function process:running() end

---Runs a command and waits for it to exit. The `start` field runs it
---without waiting.
---@class rex.Exec
---@field start fun(argv: string[], opts?: rex.ExecOptions): rex.Process?, string?
---@overload fun(argv: string[], opts?: rex.ExecOptions): rex.ExecResult?, string?
rex.exec = {}

---@class rex.JsonLib
rex.json = {}

---@param value any
---@param opts? { indent?: boolean }
---@return string?, string?
function rex.json.encode(value, opts) end

---@param text string
---@return any, string?
function rex.json.decode(text) end

---@overload fun(message: string)
---@param level "debug"|"info"|"warn"|"error"
---@param message string
function rex.log(level, message) end

---The script's arguments. Scripts run with rex do only.
---@type table
rex.args = {}

---The session the script runs against. Scripts run with rex do only.
---@type string?
rex.session_id = nil

---The block the script runs against. Scripts run with rex do only.
---@type string?
rex.block_id = nil
