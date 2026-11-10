return {
   "folke/lazydev.nvim",
   ft = "lua",
   -- Gives lua_ls the types of installed plugins on demand, so `Snacks.*`,
   -- `MiniAnimate.*` and plugin option tables complete and show docs in this config.
   opts = {
      library = {
         -- vim.uv types
         { path = "${3rd}/luv/library", words = { "vim%.uv" } },
         -- globals that are used without a require()
         { path = "snacks.nvim", words = { "Snacks" } },
         { path = "mini.nvim", words = { "Mini%u" } },
      },
   },
}
