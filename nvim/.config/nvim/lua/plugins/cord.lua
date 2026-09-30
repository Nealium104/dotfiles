return {
  "vyfor/cord.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.cord_defer_startup = true
  end,
  opts = {},
  config = function(_, opts)
    -- Headless checks should not start Discord presence.
    if #vim.api.nvim_list_uis() == 0 then return end
    require("config.discord").setup(opts)
    require("cord").setup(opts)
  end,
}
