return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
		},
		config = function()
			local telescope = require('telescope')
			local builtin = require('telescope.builtin')

			telescope.setup({
				pickers = {
					find_files = {
						hidden = true,
					},
				},
			})
			telescope.load_extension('fzf')

			-- (f)ind (h)elp
			vim.keymap.set("n", "<space>fh", builtin.help_tags)
			-- (f)ind files in (d)irectory
			vim.keymap.set("n", "<space>fd", builtin.find_files)
			-- (f)ind by (g)rep
			vim.keymap.set("n", "<space>fg", builtin.live_grep)
			-- (e)dit (n)eovim
			vim.keymap.set("n", "<space>en", function()
				builtin.find_files {
					cwd = vim.fn.stdpath("config")
				}
			end)
		end
	}
}
