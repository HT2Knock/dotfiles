return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- Recommended
  },
  {
    "epwalsh/obsidian.nvim",
    event = { "BufReadPre " .. vim.fn.expand "~" .. "/Documents/JT-notes/*.md" },
    cmd = { "ObsidianToday", "ObsidianNew", "ObsidianSearch" },
    ft = { "markdown" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      dir = vim.env.HOME .. "/Documents/JT-notes", -- specify the vault location. no need to call 'vim.fn.expand' here
      finder = "telescope.nvim",
      mappings = {},

      daily_notes = {
        folder = "dailies",
        template = "daily_note.md",
      },

      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },

      attachments = {
        img_folder = "resources/imgs",
      },

      ui = {
        enable = false,
      },
    },
  },
}
