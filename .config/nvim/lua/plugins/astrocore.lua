-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = true, -- sets vim.opt.wrap
        -- conceallevel = 2, -- enable conceal
        -- list = true, -- show whitespace characters
        -- listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
        showbreak = "↪ ",
        splitkeep = "screen",
        swapfile = false,
        guifont = "JetBrainsMono Nerd Font Mono:h9",
        linespace = 5,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["<C-q>"] = false,
        ["<C-s>"] = false,
        ["q:"] = ":",
        -- better buffer navigation
        ["]b"] = false,
        ["[b"] = false,
        ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        -- better increment/decrement
        ["-"] = { "<c-x>", desc = "Descrement number" },
        ["+"] = { "<c-a>", desc = "Increment number" },
        -- this is useful for naming menus
        ["<leader>b"] = { name = " Buffers" },
        ["<leader>k"] = { "i<Enter><Esc>", desc = "down a line" },

        -- telescope
        ["<leader>fp"] = { "<cmd>Telescope projects<cr>", desc = "Find project" },
        ["<leader>fT"] = { "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },

        -- set CWD
        ["<leader>."] = { "<cmd>cd %:p:h<cr>", desc = "Set CWD" },

        --obsidian map
        ["<leader>o"] = { name = " Notes" },
        ["<leader>od"] = { "<cmd>ObsidianToday<cr>", desc = "Daily notes today" },
        ["<leader>oy"] = { "<cmd>ObsidianYesterday<cr>", desc = "Daily notes yesterday" },
        ["<leader>op"] = { "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard" },
        ["<leader>oc"] = { "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch notes" },
        ["<leader>on"] = { "<cmd>ObsidianNew<cr>", desc = "Create a new note" },
        ["<leader>oh"] = { "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
        ["<leader>oo"] = { "<cmd>ObsidianOpen<cr>", desc = "Open obsidian note" },
        ["<leader>ob"] = { "<cmd>ObsidianBacklinks<cr>", desc = "Open list back links" },
        ["<leader>of"] = { "<cmd>ObsidianSearch<cr>", desc = "Find in notes" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
    },
  },
}
