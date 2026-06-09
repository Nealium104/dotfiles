return {
	{
		'rebelot/kanagawa.nvim',
		config = function()
			-- Paste your entire Kanagawa configuration block HERE
			require('kanagawa').setup({
				compile = false, -- compute highlights fresh each launch (avoids stale cache)
				undercurl = true, -- enable undercurls
				commentStyle = { italic = true },
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				typeStyle = {},
				terminalColors = true, -- define vim.g.terminal_color_{0,17}
			})
		end,
	}
}
