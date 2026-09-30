return {
	'lewis6991/gitsigns.nvim',
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation
			map('n', ']h', gs.next_hunk, 'Next hunk')
			map('n', '[h', gs.prev_hunk, 'Prev hunk')

			-- Actions
			map({ 'n', 'v' }, '<leader>gs', gs.stage_hunk, 'Stage hunk')
			map({ 'n', 'v' }, '<leader>gr', gs.reset_hunk, 'Reset hunk')
			map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
			map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
			map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
			map('n', '<leader>gi', gs.preview_hunk_inline, 'Preview hunk inline')
			map('n', '<leader>gb', function() gs.blame_line { full = true } end, 'Blame line')
			map('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle line blame')
			map('n', '<leader>gw', gs.toggle_word_diff, 'Toggle word diff')
			map('n', '<leader>gd', gs.diffthis, 'Diff this')
			map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
		end,
	},
}
