-- Seasonal things falling down the dashboard (leaves, snow, ... picked by
-- date), and across any buffer after 5 idle minutes.
return {
   "folke/drop.nvim",
   event = "VeryLazy",
   opts = {
      -- drop's default list doesn't know snacks' dashboard
      filetypes = { "snacks_dashboard" },
   },
}
