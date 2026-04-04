require("config.lazy")
require("config.filetypes")

-- filetype assertions
vim.filetype.add({
  extension = {
    mustache = "html",
  },
})

-- clipboard
vim.opt.clipboard = "unnamedplus"
if vim.fn.executable('xclip') == 1 then
	vim.g.clipboard = {
		name = "xclip",
		copy = {
			['+'] = 'xclip -selection clipboard -in',
			['*'] = 'xclip -selection primary -in',
		},
		paste = {
			['+'] = 'xclip -selection clipboard -out',
			['*'] = 'xclip -selection primary -out',
		},
		cache_enabled = 1,
	}
end

-- Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Looks
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.listchars = {
	tab = '~ ',
	trail = '•',
}
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })

-- LSP Keymaps
vim.diagnostic.config({
	virtual_text = true
})

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Controls
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")
