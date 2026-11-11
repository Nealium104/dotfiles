-- a dividing line across the dashboard, between its parts
local rule = { align = "center", text = { { string.rep("─", 80), hl = "footer" } } }

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
            -- a bonsai (in place of the header) with a fortune and triforce stats
            -- under it, every key on one row between two lines, then the
            -- startup time. the bonsai and fortune fall back to nothing special
            -- when their commands (apt cbonsai, fortune-mod) aren't installed
            function()
               if vim.fn.executable("cbonsai") == 0 then return { section = "header" } end
               -- leaves for the season, on the same dates drop.nvim switches its
               -- theme, so the tree matches what's falling past it
               local md = tonumber(os.date("%m%d"))
               local leaves = (md >= 320 and md <= 620) and "❀,✿,&" -- spring blossom
                  or (md >= 621 and md <= 921) and "&" -- summer
                  or (md >= 922 and md <= 1220) and "&,%,#" -- autumn
                  or "*,+,·" -- winter frost
               -- grows live (-l) for 3-10 seconds, then stays (-p). ttl 0:
               -- a new tree every time instead of snacks' cached output
               return {
                  section = "terminal",
                  cmd = ("cbonsai -lp -t 0.01 -L 40 -M 5 -c '%s'"):format(leaves),
                  height = 22,
                  ttl = 0,
               }
            end,
            function()
               if vim.fn.executable("fortune") == 0 then return nil end
               local out = vim.system({ "fortune", "-s" }, { text = true }):wait(500)
               if out.code ~= 0 or not out.stdout then return nil end
               -- the footer colour in bold, set here so it follows colorscheme changes
               local footer = vim.api.nvim_get_hl(0, { name = "SnacksDashboardFooter", link = false })
               vim.api.nvim_set_hl(0, "SnacksDashboardQuote", vim.tbl_extend("force", footer, { bold = true }))
               local items = {}
               for line in out.stdout:gsub("\t", "  "):gmatch("[^\n]+") do
                  table.insert(items, { align = "center", text = { { vim.trim(line), hl = "SnacksDashboardQuote" } } })
               end
               -- a blank line between the fortune and the triforce stats
               if #items > 0 then items[#items].padding = 1 end
               return items
            end,
            function()
               local ok, triforce = pcall(require, "triforce.stats")
               if not ok then return nil end
               local s = triforce.load()
               local function num(n) return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
               return {
                  {
                     align = "center",
                     text = {
                        { "Lv " .. s.level, hl = "special" },
                        { "  ·  " .. num(s.xp) .. " / " .. num(triforce.xp_for_next_level(s.level)) .. " XP", hl = "desc" },
                        { "  ·  󰈸 " .. s.current_streak .. "-day streak (best " .. s.longest_streak .. ")", hl = "desc" },
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
      scope = { enabled = true },
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
