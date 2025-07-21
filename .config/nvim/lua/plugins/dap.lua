return {
  { "rcarriga/nvim-dap-ui", enabled = false },
  {
    "miroshQa/debugmaster.nvim",
    config = function()
      local dm = require("debugmaster")
      vim.keymap.set({ "n", "v" }, "<leader>m", dm.mode.toggle, { nowait = true })
      dm.plugins.osv_integration.enabled = true
    end,
  },
  {
    "rareitems/printer.nvim",
    config = function()
      require("printer").setup({
        keymap = "gp",
      })
    end,
  },
}
