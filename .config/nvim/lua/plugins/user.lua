return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
  { "folke/flash.nvim", enabled = false },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = {
        preselect = true,
        auto_insert = true,
      }
      return opts
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      max_count = 5,
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      prompt_library = {
        ["Commit Message"] = {
          strategy = "inline",
          description = "Generate a commit message",
          opts = {
            short_name = "commit_message",
            auto_submit = true,
            placement = "before",
          },
          prompts = {
            {
              role = "user",
              contains_code = true,
              content = function()
                return [[You are an expert at following the Conventional Commit specification based on the following diff:
]] .. vim.fn.system("git diff --cached") .. [[
Generate a commit message for me. Return the code only and no markdown codeblocks.
                    ]]
              end,
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
