return {
	'folke/which-key.nvim',
	event = 'VeryLazy',
	opts = {
		spec = {
			{ '<leader>d', group = 'debug' },
			{ '<leader>f', group = 'find' },
			{ '<leader>h', group = 'git hunks' },
		},
	},
}
