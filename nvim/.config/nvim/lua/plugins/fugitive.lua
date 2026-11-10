return {
   "tpope/vim-fugitive",
   -- Load after startup
   event = "VeryLazy",
   keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
   },
}
