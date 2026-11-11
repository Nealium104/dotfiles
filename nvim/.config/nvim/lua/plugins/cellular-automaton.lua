-- Turns the buffer's text into falling sand (:CellularAutomaton make_it_rain)
-- or the game of life (game_of_life). Any key stops it; the text is untouched.
return {
   "Eandrju/cellular-automaton.nvim",
   cmd = "CellularAutomaton",
   keys = {
      { "<leader>ur", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Make it rain" },
   },
}
