return {
	'folke/which-key.nvim',
	event = 'VeryLazy',
	opts = {
		spec = {
			{ '<leader>c', group = 'code' },
			{ '<leader>d', group = 'debug' },
			{ '<leader>f', group = 'find' },
			{ '<leader>g', group = 'git' },
			{ '<leader>o', group = 'obsidian' },
			{ '<leader>t', group = 'trouble' },
		},
	},
}
