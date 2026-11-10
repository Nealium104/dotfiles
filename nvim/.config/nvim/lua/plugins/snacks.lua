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
         sections = {
            -- snacks' default layout, with triforce stats between the keys and
            -- startup time
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
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
                  { icon = "󰓎 ", key = "p", desc = "Triforce Profile", action = ":Triforce profile", padding = 1 },
               }
            end,
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
