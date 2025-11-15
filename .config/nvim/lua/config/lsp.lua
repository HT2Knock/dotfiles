vim.lsp.enable {
  'lua_ls',
  'stylua',
  'gopls',
  'ruff',
  'rumdl',
  'taplo',
  'bashls',
  'yamlls',
  'jsonls',
  'postgres_lsp',
  'cssls',
  'html',
  'astro',
  'tailwindcss',
}

vim.diagnostic.config {
  severity_sort = true,
  virtual_text = true,
  float = {
    border = 'rounded',
    source = true,
  },
  underline = {
    severity = vim.diagnostic.severity.ERROR,
  },
  jump = { float = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Set up document highlighting if supported by the LSP server
    -- This highlights all references to the symbol under the cursor
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

      -- Highlight references when cursor stops moving
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      -- Clear highlights when cursor moves
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })

      -- Clean up highlights when LSP detaches
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(detach_event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'lsp-highlight',
            buffer = detach_event.buf,
          }
        end,
      })
    end
  end,
})
