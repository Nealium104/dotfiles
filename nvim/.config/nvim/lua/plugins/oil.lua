return {
	'stevearc/oil.nvim',
	lazy = false, -- Load at startup so Oil handles directory buffers.
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
	},
	keys = {
		{ '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
	},
}
