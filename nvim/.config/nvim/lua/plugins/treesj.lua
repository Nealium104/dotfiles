return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>m", "<cmd>TSJToggle<cr>", desc = "Toggle split/join" },
    { "<leader>j", "<cmd>TSJJoin<cr>", desc = "Join code block" },
    { "<leader>s", "<cmd>TSJSplit<cr>", desc = "Split code block" },
  },
  opts = {
    use_default_keymaps = false,
    max_join_length = 120,
  },
}
