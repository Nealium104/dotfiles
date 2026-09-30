return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {},
  keys = {
    { "<leader>a", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
    { "<leader>tb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    { "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    { "<leader>tl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
    { "<leader>ts", "<cmd>Trouble symbols toggle<cr>", desc = "Document symbols" },
    { "<leader>tr", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references and definitions" },
  },
}
