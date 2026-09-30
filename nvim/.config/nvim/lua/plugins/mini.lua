return {
    {
	'echasnovski/mini.nvim',
	config = function ()
	    require('mini.ai').setup()
	    require('mini.icons').setup()
	    local statusline = require('mini.statusline')
	    statusline.setup({
		use_icons = true,
		content = {
		    active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local git = statusline.section_git({ trunc_width = 40 })
			local diff = statusline.section_diff({ trunc_width = 75 })
			local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
			local filename = statusline.section_filename({ trunc_width = 140 })
			local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			local location = statusline.section_location({ trunc_width = 75 })
			local search = statusline.section_searchcount({ trunc_width = 75 })

			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local client_names = vim.tbl_map(function(client)
			    return client.name
			end, clients)
			local language_tools = #client_names > 0 and table.concat(client_names, ', ') or ''

			local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
			local flags = table.concat({
			    vim.bo.modified and '[+]' or '',
			    vim.bo.readonly and 'RO' or '',
			    vim.bo.modifiable and '' or '-',
			}, ' ')
			local recording = vim.fn.reg_recording()
			recording = recording == '' and '' or ('REC @' .. recording)

			return statusline.combine_groups({
			    { hl = mode_hl, strings = { mode } },
			    { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, language_tools } },
			    { hl = 'MiniStatuslineFilename', strings = { project } },
			    '%<',
			    { hl = 'MiniStatuslineFilename', strings = { filename } },
			    '%=',
			    { hl = 'MiniStatuslineFileinfo', strings = { flags, fileinfo, recording } },
			    { hl = mode_hl, strings = { search, location } },
			})
		    end,
		},
	    })

	    -- Keep the richer statusline visually quiet and tied to whichever
	    -- Catppuccin flavour is active, including after :colorscheme changes.
	    local statusline_palette_group = vim.api.nvim_create_augroup('catppuccin-mini-statusline', { clear = true })
	    vim.api.nvim_create_autocmd('ColorScheme', {
		group = statusline_palette_group,
		pattern = 'catppuccin*',
		callback = function()
		    local colors = require('catppuccin.palettes').get_palette()
		    local set_hl = vim.api.nvim_set_hl

		    set_hl(0, 'MiniStatuslineDevinfo', { fg = colors.subtext0, bg = colors.mantle })
		    set_hl(0, 'MiniStatuslineFilename', { fg = colors.text, bg = colors.base, bold = true })
		    set_hl(0, 'MiniStatuslineFileinfo', { fg = colors.overlay2, bg = colors.mantle })
		    set_hl(0, 'MiniStatuslineInactive', { fg = colors.overlay0, bg = colors.crust })
		    set_hl(0, 'MiniStatuslineModeNormal', { fg = colors.blue, bg = colors.surface0, bold = true })
		    set_hl(0, 'MiniStatuslineModeInsert', { fg = colors.green, bg = colors.surface0, bold = true })
		    set_hl(0, 'MiniStatuslineModeVisual', { fg = colors.mauve, bg = colors.surface0, bold = true })
		    set_hl(0, 'MiniStatuslineModeReplace', { fg = colors.red, bg = colors.surface0, bold = true })
		    set_hl(0, 'MiniStatuslineModeCommand', { fg = colors.peach, bg = colors.surface0, bold = true })
		    set_hl(0, 'MiniStatuslineModeOther', { fg = colors.teal, bg = colors.surface0, bold = true })
		end,
	    })
	    require('mini.pairs').setup()
	    require('mini.sessions').setup()
	    require('mini.surround').setup()
	end
    }
}
