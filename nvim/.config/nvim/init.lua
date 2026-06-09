require("config.lazy")
require("config.filetypes")

-- Colorscheme
vim.cmd.colorscheme("everforest")

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
vim.opt.number = true -- line number
vim.opt.relativenumber = true
vim.opt.wrap = false -- don't wrap lines
vim.opt.sidescrolloff = 10 -- keep 10 characters left and right of cursor

-- Looks
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.tabstop = 4 -- use 4 spaces per tab
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- get indent from current line
vim.opt.signcolumn = "yes" -- show sign column
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.scrolloff = 10 -- keep 10 lines above and below of cursor
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.ignorecase = true -- ignore case for searches
vim.opt.swapfile = false -- do not create swapfiles
vim.opt.autoread = true -- reload the file if changes outside neovim happen
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
