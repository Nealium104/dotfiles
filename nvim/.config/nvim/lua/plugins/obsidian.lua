return {
  "obsidian-nvim/obsidian.nvim",
  version = "3.*",
  ft = "markdown",
  cmd = "Obsidian",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-treesitter/nvim-treesitter" },
  opts = {
    legacy_commands = false,
    workspaces = { { name = "The Brain", path = "~/obsidian/" } },
    notes_subdir = "1. Inbox",
    new_notes_location = "notes_subdir",
    templates = { folder = "Templates", date_format = "YYYY-MM-DD", time_format = "HH:mm" },
    daily_notes = {
      folder = "1. Inbox/Daily",
      date_format = "YYYY-MM-DD",
      template = "Daily.md",
      workdays_only = false,
    },
    -- render-markdown.nvim handles display; Obsidian handles checkbox changes.
    ui = { enable = false },
    checkbox = { order = { " ", "x", ">", "~", "!" } },
    picker = { name = "telescope.nvim", note_mappings = { new = "<C-x>" } },
    callbacks = {
      enter_note = function()
        local function map(lhs, command, desc)
          vim.keymap.set("n", lhs, "<cmd>Obsidian " .. command .. "<cr>", { buffer = true, desc = desc })
        end
        map("<leader>ot", "today", "Today's note")
        map("<leader>oq", "quick_switch", "Quick switch")
        map("<leader>os", "search", "Search vault")
        map("<leader>ob", "backlinks", "Backlinks")
        map("<leader>of", "follow_link", "Follow link")
        map("<leader>ch", "toggle_checkbox", "Toggle checkbox")
      end,
    },
  },
}
