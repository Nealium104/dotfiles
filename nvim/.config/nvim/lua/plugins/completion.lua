return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  dependencies = { "abecodes/tabout.nvim" },
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-y>"] = { "select_and_accept", "fallback" },
    },
    completion = {
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true },
    },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    signature = { enabled = true },
    -- Avoid a separate native binary or compiler dependency.
    fuzzy = { implementation = "lua" },
  },
}
