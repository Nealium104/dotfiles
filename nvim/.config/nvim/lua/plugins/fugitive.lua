return {
   "tpope/vim-fugitive",
   -- Load after startup
   event = "VeryLazy",
   keys = {
      -- open in split while working; open in-place on dashboard
      -- dashboard re-renders cause the windows to break
      {
         "<leader>gg",
         function() vim.cmd(vim.bo.filetype == "snacks_dashboard" and "Gedit :" or "Git") end,
         desc = "Git status (fugitive)",
      },
      -- Files changed since the last commit (staged and unstaged) into the quickfix list
      { "<leader>gc", "<cmd>Git difftool --name-only HEAD<cr>", desc = "Changed files (quickfix)" },
      -- Files with merge conflicts into the quickfix list
      { "<leader>gm", "<cmd>Git mergetool<cr>", desc = "Merge conflicts (quickfix)" },
   },
}
