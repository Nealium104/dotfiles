-- a dividing line across the dashboard, between its parts
local rule = { align = "center", text = { { string.rep("─", 80), hl = "footer" } } }

-- The bonsai takes whatever height the rest of the dashboard leaves, so the
-- last line sits at the bottom of the window. The rest varies (the quote wraps
-- to more or fewer lines), so after each draw the dashboard is measured and,
-- if the tree should be taller or shorter, drawn once more at that height.
-- The quote is kept between draws (only a new tree brings a new one) so that
-- second draw comes out the same size.
local bonsai = { height = 28, min = 8 }
local quote_state = { quote = nil, fresh = true }
vim.api.nvim_create_autocmd("User", {
   pattern = "SnacksDashboardUpdatePost",
   group = vim.api.nvim_create_augroup("dashboard-bonsai-height", { clear = true }),
   callback = function()
      local dash = bonsai.dash
      if not (dash and dash.lines and dash._size) then return end
      local used = #dash.lines - dash.row -- dash.lines starts with the centring blank lines
      local height = math.max(bonsai.min, bonsai.height + dash._size.height - used)
      if height ~= bonsai.height then
         bonsai.height = height
         vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "SnacksDashboardUpdate" }) end)
      end
   end,
})

return {
   "folke/snacks.nvim",
   -- The dashboard must load at startup, before other UI plugins.
   priority = 1000,
   lazy = false,
   keys = {
      {
         "<leader>go",
         function() Snacks.gitbrowse() end,
         mode = { "n", "v" },
         desc = "Open in browser",
      },
      {
         "<leader>n",
         function() Snacks.notifier.show_history() end,
         desc = "Notification history",
      },
      {
         "<leader>un",
         function() Snacks.notifier.hide() end,
         desc = "Dismiss notifications",
      },
   },
   init = function()
      -- LSP progress as one notification with a spinner, updated in place
      -- (same id) instead of stacking new popups.
      vim.api.nvim_create_autocmd("LspProgress", {
         group = vim.api.nvim_create_augroup("snacks-lsp-progress", { clear = true }),
         ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
         callback = function(ev)
            local spinner = {
               "⠋",
               "⠙",
               "⠹",
               "⠸",
               "⠼",
               "⠴",
               "⠦",
               "⠧",
               "⠇",
               "⠏",
            }
            vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
               id = "lsp_progress",
               title = "LSP Progress",
               opts = function(notif)
                  notif.icon = ev.data.params.value.kind == "end" and " "
                     or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
               end,
            })
         end,
      })
   end,
   opts = {
      dashboard = {
         enabled = true,
         -- room for the bonsai, and exactly the width of the key row below
         width = 80,
         sections = {
            function(self)
               if vim.fn.executable("cbonsai") == 0 then return { section = "header" } end
               bonsai.dash = self
               -- leaves for the season, on the same dates drop.nvim switches its
               -- theme, so the tree matches what's falling past it
               local md = tonumber(os.date("%m%d"))
               local leaves = (md >= 320 and md <= 620) and "❀,✿,&" -- spring blossom
                  or (md >= 621 and md <= 921) and "&" -- summer
                  or (md >= 922 and md <= 1220) and "&,%,#" -- autumn
                  or "*,+,·" -- winter frost

               vim.api.nvim_create_autocmd("TermClose", {
                  group = vim.api.nvim_create_augroup("dashboard-bonsai", { clear = true }),
                  callback = function(ev)
                     if vim.v.event.status ~= 0 or not vim.api.nvim_buf_get_name(ev.buf):find("cbonsai", 1, true) then return end
                     local showing = vim.tbl_contains(vim.api.nvim_list_wins(), function(win)
                        return vim.api.nvim_win_get_config(win).relative == ""
                           and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard"
                     end, { predicate = true })
                     if showing then
                        quote_state.fresh = true -- a new tree, a new quote
                        vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "SnacksDashboardUpdate" }) end)
                     end
                  end,
               })
               -- life (-L) grows with the room, so a taller window gets a taller
               -- tree: 40 suited the old fixed 28 rows; cbonsai allows up to 200
               local life = math.min(200, math.floor(40 * bonsai.height / 28))
               return {
                  section = "terminal",
                  -- the sleep is the pause between trees, with the finished one shown
                  cmd = ("cbonsai -l -p -t 0.06 -L %d -M 5 -c '%s'; sleep 10"):format(life, leaves),
                  height = bonsai.height,
                  ttl = 0,
               }
            end,
            -- a short quote from the obsidian vault, a kindle highlight or a
            -- quote note (config/quote.lua picks one and leaves out long
            -- passages)
            function()
               local quotes = require("config.quote")
               if quote_state.fresh then
                  local ok, picked = pcall(quotes.random)
                  quote_state.quote, quote_state.fresh = ok and picked or nil, false
               end
               local quote = quote_state.quote
               if not quote then return nil end
               -- colours from the catppuccin palette, set here so they follow a
               -- flavour change. without catppuccin: the dashboard's description
               -- colour on the cursorline background
               local has_palette, palette = pcall(function() return require("catppuccin.palettes").get_palette() end)
               local fg, credit_fg, bg
               if has_palette then
                  fg, credit_fg, bg = palette.blue, palette.overlay2, palette.surface0
               else
                  fg = vim.api.nvim_get_hl(0, { name = "SnacksDashboardDesc", link = false }).fg
                  credit_fg, bg = fg, vim.api.nvim_get_hl(0, { name = "CursorLine", link = false }).bg
               end
               vim.api.nvim_set_hl(0, "SnacksDashboardQuote", { fg = fg, bg = bg, bold = true, italic = true })
               vim.api.nvim_set_hl(0, "SnacksDashboardQuoteCredit", { fg = credit_fg, bg = bg, italic = true })
               vim.api.nvim_set_hl(0, "SnacksDashboardQuoteCard", { bg = bg })

               local rows = {} ---@type { [1]: string, [2]: string }[] text, highlight
               for _, line in ipairs(quotes.wrap(quote.text, 68)) do
                  table.insert(rows, { line, "SnacksDashboardQuote" })
               end
               local credit = quotes.credit(quote)
               if credit then table.insert(rows, { credit, "SnacksDashboardQuoteCredit" }) end
               -- every row padded to the same width, two spaces either side of
               -- the longest, so the background is a block instead of ragged
               -- edges; a blank row above and below
               local width = 0
               for _, row in ipairs(rows) do width = math.max(width, vim.fn.strdisplaywidth(row[1])) end
               width = width + 4
               local function row_item(text, hl)
                  local left = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
                  local right = width - vim.fn.strdisplaywidth(text) - left
                  return { align = "center", text = { { (" "):rep(left) .. text .. (" "):rep(right), hl = hl } } }
               end
               local items = { row_item("", "SnacksDashboardQuoteCard") }
               for _, row in ipairs(rows) do table.insert(items, row_item(row[1], row[2])) end
               table.insert(items, row_item("", "SnacksDashboardQuoteCard"))
               -- a blank line between the card and the triforce stats
               items[#items].padding = 1
               return items
            end,
            function()
               local ok, triforce = pcall(require, "triforce.stats")
               if not ok then return nil end
               local s = triforce.load()
               local function num(n) return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
               -- the streak's flame in orange (catppuccin's peach)
               local has_palette, palette = pcall(function() return require("catppuccin.palettes").get_palette() end)
               vim.api.nvim_set_hl(0, "SnacksDashboardStreak", has_palette and { fg = palette.peach } or { link = "DiagnosticWarn" })
               return {
                  {
                     align = "center",
                     text = {
                        { "Lv " .. s.level, hl = "special" },
                        { "  ·  " .. num(s.xp) .. " / " .. num(triforce.xp_for_next_level(s.level)) .. " XP", hl = "desc" },
                        { "  ·  ", hl = "desc" },
                        { "󰈸", hl = "SnacksDashboardStreak" },
                        { " " .. s.current_streak .. "-day streak (best " .. s.longest_streak .. ")", hl = "desc" },
                     },
                  },
               }
            end,
            rule,
            -- every key on one row, so the bonsai gets the height. the preset's
            -- items stay, hidden, so their keymaps still work
            function(self)
               local labels = { f = "files", n = "new", g = "grep", r = "recent", c = "config", s = "session", L = "lazy", q = "quit" }
               local keys = vim.tbl_filter(function(k) return k.enabled ~= false end, vim.deepcopy(self.opts.preset.keys))
               if pcall(require, "triforce.stats") then
                  table.insert(keys, #keys, { key = "p", desc = "profile", action = ":Triforce profile" })
               end
               local text = {}
               for i, k in ipairs(keys) do
                  k.hidden = true
                  if i > 1 then table.insert(text, { "  " }) end
                  table.insert(text, { k.key, hl = "key" })
                  table.insert(text, { " " .. (labels[k.key] or k.desc:lower()), hl = "desc" })
               end
               table.insert(keys, { align = "center", text = text })
               return keys
            end,
            rule,
            { section = "startup" },
         },
      },
      -- Disable LSP, treesitter, and animations in very large files (default > 1.5MB)
      bigfile = { enabled = true },
      -- Floating prompt for vim.ui.input (e.g. LSP rename)
      input = { enabled = true },
      notifier = {
         enabled = true,
         top_down = false,
         width = { min = 40, max = 0.4 },
         height = {mid = 1, max = 0.6 },
         gap = 1,
         margin = {
            top = 0,
            right = 1,
            bottom = 1,
         },
      },
      scope = { enabled = true, cursor = false },
      indent = {
         enabled = true,
         indent = {
            char = "┊", -- "│", "┊", "▏"
            only_scope = false,
            only_current = false,
         },
         animate = {
            enabled = true,
            style = "up_down",
            -- inOutElastic returns NaN for one-line scopes (zero change) and crashes the redraw
            easing = "outCubic",
            duration = { step = 10, total = 200 },
         },
         scope = {
            enabled = true,
            char = "│",
            underline = false,
            hl = "SnacksIndentScope",
         }
      },
   },
}
