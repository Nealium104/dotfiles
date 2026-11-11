-- Typing practice in a floating window (:Typr), with stats over time
-- (:TyprStats). Same author as volt, which triforce already pulls in.
return {
   "nvzone/typr",
   dependencies = { "nvzone/volt" },
   cmd = { "Typr", "TyprStats" },
   keys = {
      { "<leader>ut", "<cmd>Typr<cr>", desc = "Typing practice (typr)" },
   },
   opts = {
      -- typr only turns off nvim-cmp; this keeps blink's menu out of the drill
      on_attach = function(buf) vim.b[buf].completion = false end,
   },
}
