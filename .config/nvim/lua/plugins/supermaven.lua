return {
  "supermaven-inc/supermaven-nvim",
  opts = {
    keymaps = {
      accept_suggestion = "<C-f>",
      clear_suggestion = "<Nop>",
      accept_word = "<C-l>",
    },
    log_level = "warn",
    disable_inline_completion = false, -- disables inline completion for use with cmp
    disable_keymaps = false, -- disables built in keymaps for more manual control
    ignore_filetypes = { markdown = true },
  },
}
