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
			-- (f)ind open (b)uffers / (r)ecent files / (R)esume picker
			vim.keymap.set("n", "<space>fb", builtin.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<space>fr", builtin.oldfiles, { desc = "Find recent files" })
			vim.keymap.set("n", "<space>fR", builtin.resume, { desc = "Resume finder" })
			-- (e)dit (n)eovim
			vim.keymap.set("n", "<space>en", function()
				builtin.find_files {
					cwd = vim.fn.stdpath("config")
				}
            end)
            -- (f)ind (obsidian)
            vim.keymap.set("n", "<space>fo", function()
                builtin.find_files {
                    cwd = vim.fn.expand("~/obsidian")
                }
              end)
		end
	}
}
