-- Override individual server settings by extending lspconfig's defaults.
-- This deep-merges with nvim-lspconfig's configs — no need to maintain full files.
--
-- Example: tweak gopls to use gofumpt by default
--   vim.lsp.config('gopls', {
--     settings = { gopls = { formatting = { gofumpt = true } } },
--   })
--
-- Example: custom lua-language-server settings
--   vim.lsp.config('lua_ls', {
--     settings = {
--       Lua = {
--         completion = { callSnippet = 'Replace' },
--         diagnostics = { disable = { 'missing-fields' } },
--       },
--     },
--   })

vim.lsp.codelens.enable(true)
vim.lsp.inlay_hint.enable(true)

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      directoryFilters = { '-node_modules', '-.git', '-.github', '-bin', '-build' },
      gofumpt = true,
      usePlaceholders = true,
      staticcheck = true,

      analyses = {
        fieldalignment = true,
        shadow = true,
        unusedwrite = true,
        useany = true,
        nilness = true,
        unusedparams = true,
      },

      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

vim.diagnostic.config {
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

    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })

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
