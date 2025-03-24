return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        enabled = true,
      },
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
    },
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Document/T2Knock/JT-notes/*.md",
    },
    opts = {
      dir = vim.env.HOME .. "/Documents/T2Knock/JT-notes",
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
    keys = {
      { "<leader>o", name = " Notes" },
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today Note" },
      { "<leader>oy", "<cmd>ObsidianYesterday <cr>", desc = "Yesteday Note" },
      { "<leader>of", "<cmd>ObsidianSearch<cr>", desc = "Find in notes" },
      { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard" },
      { "<leader>oc", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch notes" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Create a new note" },
      { "<leader>oh", "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
    },
  },
}
