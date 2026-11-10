return {
   'folke/which-key.nvim',
   event = 'VeryLazy',
   opts = {
      spec = {
         { '<leader>c', group = 'code' },
         { '<leader>d', group = 'debug' },
         { '<leader>e', group = 'edit' },
         { '<leader>f', group = 'find' },
         { '<leader>g', group = 'git' },
         { '<leader>o', group = 'obsidian' },
         { '<leader>S', group = 'session' },
         { '<leader>t', group = 'trouble' },
         { '<leader>u', group = 'ui/toggles' },
      },
   },
}
