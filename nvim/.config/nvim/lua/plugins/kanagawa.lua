return {
	{
		'rebelot/kanagawa.nvim',
		config = function()
			-- Paste your entire Kanagawa configuration block HERE
			require('kanagawa').setup({
				compile = true, -- enable compiling the colorscheme
				undercurl = true, -- enable undercurls
				commentStyle = { italic = true },
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				typeStyle = {},
				terminalColors = true, -- define vim.g.terminal_color_{0,17}
				transparent = true
			})
			vim.cmd("colorscheme kanagawa-wave")
		end,
	}
}
