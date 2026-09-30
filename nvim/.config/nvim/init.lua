require("config.lazy")
require("config.filetypes")

-- Colorscheme
vim.cmd.colorscheme("catppuccin-frappe")

-- filetype assertions
vim.filetype.add({
  extension = {
    mustache = "html",
  },
})

-- clipboard
-- Keep deletes/changes in local registers; only ordinary yanks update the OS clipboard.
vim.opt.clipboard = ""
-- Access Windows directly under WSL, including when running inside tmux.
if vim.fn.has('wsl') == 1 and vim.fn.executable('powershell.exe') == 1 then
	local powershell = { 'powershell.exe', '-NoLogo', '-NoProfile', '-NonInteractive', '-Command' }
	local copy = vim.list_extend(vim.deepcopy(powershell), {
		'[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); Set-Clipboard -Value ([Console]::In.ReadToEnd())',
	})
	local paste = vim.list_extend(vim.deepcopy(powershell), {
		'[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); [Console]::Out.Write(([string](Get-Clipboard -Raw)).Replace("`r", ""))',
	})
	vim.g.clipboard = {
		name = 'Windows clipboard (WSL)',
		copy = { ['+'] = copy, ['*'] = copy },
		paste = { ['+'] = paste, ['*'] = paste },
		-- Start clipboard copies asynchronously.
		cache_enabled = 1,
	}
elseif vim.fn.executable('xclip') == 1 then
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

-- Respect explicit registers (including the black hole register).
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Copy ordinary yanks to the system clipboard",
	group = vim.api.nvim_create_augroup("yank-system-clipboard", { clear = true }),
	callback = function()
		local event = vim.v.event
		if event.operator == "y" and event.regname == "" then
			vim.fn.setreg("+", event.regcontents, event.regtype)
		end
	end,
})

-- Preserve editor defaults previously set by CoC.
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300

-- Numbers
vim.opt.number = true -- line number
vim.opt.relativenumber = true
vim.opt.wrap = true -- wrap long lines

-- Looks
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.tabstop = 4 -- use 4 spaces per tab
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- get indent from current line
vim.opt.signcolumn = "yes" -- show sign column
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.scrolloff = 10 -- keep 10 lines above and below of cursor
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.ignorecase = true -- ignore case for searches
vim.opt.smartcase = true -- match case when the search includes uppercase letters
vim.opt.swapfile = false -- do not create swapfiles
vim.opt.autoread = true -- reload the file if changes outside neovim happen
vim.opt.listchars = {
	tab = '~ ',
	trail = '•',
}
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.opt.conceallevel = 1

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

-- Tools
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
