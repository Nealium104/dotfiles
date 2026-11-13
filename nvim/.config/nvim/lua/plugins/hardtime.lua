return {
   "m4xshen/hardtime.nvim",
   event = "VeryLazy",
   dependencies = { "MunifTanjim/nui.nvim" },
   keys = {
      { "<leader>uh", "<cmd>Hardtime toggle<cr>", desc = "Toggle hardtime" },
   },
   opts = {
      hints = {
         ["xi"] = { message = function() return "Use s instead of xi" end, length = 2 },
         ["%D0i"] = { message = function() return "Use I instead of 0i" end, length = 3 },
         ["%D0w"] = { message = function() return "Use ^ instead of 0w" end, length = 3 },
      },
   },
}
