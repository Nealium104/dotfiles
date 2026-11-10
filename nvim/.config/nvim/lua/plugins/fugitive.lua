return {
   "tpope/vim-fugitive",
   -- Load after startup
   event = "VeryLazy",
   keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
      -- Files changed since the last commit (staged and unstaged) into the quickfix list
      { "<leader>gc", "<cmd>Git difftool --name-only HEAD<cr>", desc = "Changed files (quickfix)" },
      -- Files with merge conflicts into the quickfix list
      { "<leader>gm", "<cmd>Git mergetool<cr>", desc = "Merge conflicts (quickfix)" },
   },
}
