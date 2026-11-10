return {
   {
      'nvim-telescope/telescope.nvim',
      dependencies = {
         'nvim-lua/plenary.nvim',
         { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
         -- Route vim.ui.select (code actions, etc.) through Telescope
         'nvim-telescope/telescope-ui-select.nvim',
      },
      -- Loads on first use (these keys, :Telescope, or a require) instead of at startup.
      cmd = 'Telescope',
      keys = {
         -- (f)ind (h)elp / files in (d)irectory / by (g)rep
         { '<space>fh', function() require('telescope.builtin').help_tags() end, desc = 'Find help' },
         { '<space>fd', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
         { '<space>fg', function() require('telescope.builtin').live_grep() end, desc = 'Find by grep' },
         -- (f)ind open (b)uffers / (r)ecent files / (R)esume picker
         { '<space>fb', function() require('telescope.builtin').buffers() end, desc = 'Find buffers' },
         { '<space>fr', function() require('telescope.builtin').oldfiles() end, desc = 'Find recent files' },
         { '<space>fR', function() require('telescope.builtin').resume() end, desc = 'Resume finder' },
         -- (e)dit (n)eovim
         {
            '<space>en',
            function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') }) end,
            desc = 'Edit Neovim config',
         },
         -- (f)ind (obsidian)
         {
            '<space>fo',
            function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('~/obsidian') }) end,
            desc = 'Find Obsidian notes',
         },
      },
      init = function()
         -- Until Telescope loads, vim.ui.select is Neovim's plain list. Load it on
         -- the first select (code actions, session picker, ...); the ui-select
         -- extension then replaces vim.ui.select, and the call is forwarded to it.
         local builtin_select = vim.ui.select
         local function lazy_select(...)
            require('lazy').load({ plugins = { 'telescope.nvim' } })
            -- If loading didn't replace it (e.g. an error), fall back rather than recurse.
            if vim.ui.select == lazy_select then vim.ui.select = builtin_select end
            return vim.ui.select(...)
         end
         vim.ui.select = lazy_select
      end,
      config = function()
         local telescope = require('telescope')

         telescope.setup({
            pickers = {
               find_files = {
                  hidden = true,
               },
            },
            extensions = {
               ['ui-select'] = { require('telescope.themes').get_dropdown() },
            },
         })
         telescope.load_extension('fzf')
         telescope.load_extension('ui-select')
      end
   }
}
