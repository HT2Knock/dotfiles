return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gt", group = "Go tools" },
      },
    },
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    build = function()
      vim.cmd.GoInstallDeps()
    end,
    opts = {},
    keys = {
      { "<leader>gtj", "<cmd>GoTagAdd json<cr>", desc = "Add json struct tags" },
      { "<leader>gty", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml struct tags" },
      { "<leader>gte", "<cmd>GoIfErr<cr>", desc = "Add if error" },
    },
  },
}
