-- all the options setting
reload("user.options")

-- general
lvim.log.level = "info"
lvim.format_on_save = true
lvim.transparent_window = false
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"

-- remove default key bindings
lvim.lsp.buffer_mappings.normal_mode["K"] = nil

-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<Esc>"] = ":noh<cr>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["K"] = "i<Enter><Esc>"

lvim.lsp.buffer_mappings.normal_mode["gh"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show hover" }

-- -- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["O"] = { "<cmd>SymbolsOutline<CR>", "Symbol" }

lvim.keys.normal_mode["<F9>"] = "<cmd>lua require'dap'.toggle_breakpoint()<cr>"
lvim.keys.normal_mode["<F5>"] = "<cmd>lua require'dap'.continue()<cr>"
lvim.keys.normal_mode["<F10>"] = "<cmd>lua require'dap'.step_over()<cr>"
lvim.keys.normal_mode["<F11>"] = "<cmd>lua require'dap'.step_into()<cr>"
lvim.keys.normal_mode["<F12>"] = "<cmd>lua require'dap'.step_out()<cr>"

lvim.builtin.which_key.mappings["d"] = {
  name = "Debug",
  b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
  c = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
  d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
  g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
  p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
  r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
  q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
  u = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
}

lvim.builtin.which_key.mappings["R"] = {
  name = "Spectre",
  p = { "<cmd>lua require('spectre').open()<cr>", "Replace word in project" },
  w = { "<cmd>lua require('spectre').open_visual({selected_word=true})<cr>", "Replace visually selected word" },
  f = { "<cmd>lua require('spectre').open_file_search()<cr>", "Replace word in current buffer" },
}

-- Change theme settings
lvim.colorscheme = "nord"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.dap.ui.config.force_buffers = true
lvim.builtin.dap.ui.config.layouts = {
  {
    elements = {
      { id = "scopes",      size = 0.33 },
      { id = "breakpoints", size = 0.17 },
      { id = "stacks",      size = 0.25 },
      { id = "watches",     size = 0.25 },
    },
    size = 0.33,
    position = "left",
  },
  {
    elements = {
      { id = "repl",    size = 0.45 },
      { id = "console", size = 0.55 },
    },
    size = 0.27,
    position = "bottom",
  },
}

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- always installed on startup, useful for parsers without a strict filetype
lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
lvim.lsp.on_attach_callback = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  --Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

-- manually setting up lsp
require("lvim.lsp.manager").setup("lua_ls")

-- Formatter
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { command = "stylua" },
  {
    command = "prettier",
    extra_args = { "--print-width", "100" },
    filetypes = { "html", "css", "markdown", "typescriptreact" },
  },
  { command = "eslint_d", filetypes = { "javascript", "typescript" } },
})

-- Linters
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { command = "cspell", filetypes = { "markdown", "typescript", "javascript" } },
  { command = "flake8", filetypes = { "python" } },
  {
    command = "shellcheck",
    args = { "--severity", "warning" },
  },
  { command = "eslint_d", filetypes = { "typescript", "javascript" } },
})

-- Code actions
local code_actions = require("lvim.lsp.null-ls.code_actions")
code_actions.setup({
  {
    command = "cspell",
  },
  {
    command = "gitsigns",
  },
  { command = "eslint_d", filetypes = { "typescript", "javascript" } },
})

-- DAP
local dap = require("dap")
dap.adapters.node2 = {
  type = "executable",
  command = "node-debug2-adapter",
  name = "node debug",
}

-- js and typs dap
dap.configurations.typescript = {
  {
    name = "Launch",
    type = "node2",
    request = "launch",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
  },
  {
    -- For this to work you need to make sure the node process is started with the `--inspect` flag.
    name = "Attach to port 9229",
    type = "node2",
    request = "attach",
    skipFiles = { "<node_internals>/**" },
    port = "9229",
    restart = true,
  },
}
--Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
lvim.plugins = {
  { 'mtdl9/vim-log-highlighting' },
  { 'shaunsingh/nord.nvim' },
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()'
  },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require('symbols-outline').setup()
    end
  },
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
    end,
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require("neoscroll").setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil, -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
      })
    end,
  },
}

-- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.json", "*.jsonc", "*.md" },
  command = "setlocal wrap",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})
