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
         -- (f)ind
            -- (h)elp - search neovim help (plugins as well)
            -- (f)iles - search for files in working directory
            -- (g)rep - search a pattern in working directory
            -- (b)uffers
            -- (r)ecent files
            -- (R)esume picker
            -- (o)bsidian files
            -- (k)eymaps - search every mapping and its description
            -- (w)ord - grep the word under the cursor in working directory
         {
            '<space>fh',
            function() require('telescope.builtin').help_tags() end,
            desc = 'Find help',
         },
         {
            '<space>ff',
            function() require('telescope.builtin').find_files() end,
            desc = 'Find files',
         },
         {
            '<space>fg',
            function() require('telescope.builtin').live_grep() end,
            desc = 'Find by grep',
         },
         {
            '<space>fb',
            function() require('telescope.builtin').buffers() end,
            desc = 'Find buffers',
         },
         {
            '<space>fr',
            function() require('telescope.builtin').oldfiles() end,
            desc = 'Find recent files',
         },
         {
            '<space>fR',
            function() require('telescope.builtin').resume() end,
            desc = 'Resume finder',
         },
         {
            '<space>fo',
            function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('~/obsidian') }) end,
            desc = 'Find Obsidian notes',
         },
         {
            '<space>fk',
            function() require('telescope.builtin').keymaps() end,
            desc = 'Find keymaps',
         },
         {
            '<space>fw',
            function() require('telescope.builtin').grep_string() end,
            desc = 'Find word under cursor',
         },

         -- (e)dit
            -- (n)eovim - edit neovim config
            -- (h)istory - edit history file
            -- (d)otfiles - edit dotfiles repo
         {
            '<space>en',
            function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') }) end,
            desc = 'Edit Neovim config',
         },
         {
            '<space>eh',
            '<cmd>edit ~/.bash_history<cr>',
            desc = 'Edit bash history file',
         },
         {
            '<space>ed',
            function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('~/dotfiles') }) end,
            desc = 'Edit dotfiles',
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
                  file_ignore_patterns = { '^%.git/'}
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
