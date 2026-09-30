return {
  "abecodes/tabout.nvim",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- Blink wraps these mappings and falls back to tabout when its menu is closed.
  opts = { completion = false },
}
