-- A duck that wanders around the window while you work. <leader>p is the pet
-- group (which-key.lua).
return {
   "tamton-aquib/duck.nvim",
   keys = {
      { "<leader>pp", function() require("duck").hatch() end, desc = "Hatch a duck" },
      { "<leader>pc", function() require("duck").cook() end, desc = "Cook a duck" },
   },
}
