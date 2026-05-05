return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = false,
      hide_during_completion = true,
      debounce = 75,
      trigger_on_accept = true,
      keymap = {
        accept = '<Tab>',
        accept_word = false,
        accept_line = false,
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
        toggle_auto_trigger = false,
      },
    },
    panel = { enabled = false },
  },
  config = function(_, opts)
    require('copilot').setup(opts)
    vim.cmd 'Copilot disable'
  end,
}
