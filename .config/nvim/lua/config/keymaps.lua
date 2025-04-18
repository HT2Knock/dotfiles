-- bad habit keymap
vim.keymap.set("n", "<leader>k", "i<Enter><Esc>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")

vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
