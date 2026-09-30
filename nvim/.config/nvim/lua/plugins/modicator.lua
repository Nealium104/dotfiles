return {
  "mawkler/modicator.nvim",
  event = "VeryLazy",
  init = function()
    -- Required by modicator.nvim to color the current line number by mode.
    vim.opt.cursorline = true
  end,
  config = function()
    local modicator = require("modicator")

    local function apply_catppuccin_mode_colors()
      local colors = require("catppuccin.palettes").get_palette()
      local set_hl = vim.api.nvim_set_hl

      -- Modicator reads these groups to style CursorLineNr. Keep them in sync
      -- with the quieter mode accents used by mini.statusline.
      set_hl(0, "NormalMode", { fg = colors.blue, bold = true })
      set_hl(0, "InsertMode", { fg = colors.green, bold = true })
      set_hl(0, "VisualMode", { fg = colors.mauve, bold = true })
      set_hl(0, "ReplaceMode", { fg = colors.red, bold = true })
      set_hl(0, "CommandMode", { fg = colors.peach, bold = true })
      set_hl(0, "SelectMode", { fg = colors.mauve, bold = true })
      set_hl(0, "TerminalMode", { fg = colors.teal, bold = true })
      set_hl(0, "TerminalNormalMode", { fg = colors.blue, bold = true })

      modicator.set_cursor_line_highlight(modicator.hl_name_from_mode(vim.api.nvim_get_mode().mode))
    end

    modicator.setup({ show_warnings = false })
    local modicator_palette_group = vim.api.nvim_create_augroup("catppuccin-modicator", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = modicator_palette_group,
      pattern = "catppuccin*",
      callback = apply_catppuccin_mode_colors,
    })
    apply_catppuccin_mode_colors()
  end,
}
