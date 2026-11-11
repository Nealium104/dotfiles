-- Seasonal things falling down the dashboard (leaves, snow, ... picked by
-- date), and across any buffer after 5 idle minutes.

-- Over the dashboard's quote card, a leaf takes the card's background: drop
-- draws each one opaque on the editor background, which otherwise punches a
-- dark square in the card. drop.nvim has no option for this, so it wraps its
-- Drop:show(); the class isn't exported, so it's found as an upvalue of
-- drop.update. If drop changes, this quietly does nothing.
local function card_background()
   local ok, drop = pcall(require, "drop.drop")
   if not ok then return end
   local Drop
   for i = 1, 50 do
      local name, value = debug.getupvalue(drop.update, i)
      if not name then break end
      if name == "Drop" then Drop = value break end
   end
   if type(Drop) ~= "table" or type(Drop.show) ~= "function" then return end

   local card ---@type { top: integer, bottom: integer, left: integer, right: integer }? screen cells, 0-based, inclusive
   local made = {} ---@type table<string, boolean> the "…Card" copies of drop's highlights made so far
   local card_hls = { SnacksDashboardQuote = true, SnacksDashboardQuoteCredit = true, SnacksDashboardQuoteCard = true }

   -- where the card is on screen, from the dashboard's extmarks
   local function find_card()
      card, made = nil, {}
      local ns = require("snacks.dashboard").ns
      for _, win in ipairs(vim.api.nvim_list_wins()) do
         local buf = vim.api.nvim_win_get_buf(win)
         if vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].filetype == "snacks_dashboard" then
            for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
               local row, col, details = mark[2], mark[3], mark[4]
               if card_hls[details.hl_group] and details.end_col then
                  local first = vim.fn.screenpos(win, row + 1, col + 1)
                  local last = vim.fn.screenpos(win, row + 1, details.end_col)
                  if first.row > 0 then
                     card = card or { top = math.huge, bottom = -1, left = math.huge, right = -1 }
                     card.top, card.bottom = math.min(card.top, first.row - 1), math.max(card.bottom, first.row - 1)
                     card.left, card.right = math.min(card.left, first.col - 1), math.max(card.right, last.col - 1)
                  end
               end
            end
            return
         end
      end
   end

   local group = vim.api.nvim_create_augroup("drop-quote-card", { clear = true })
   vim.api.nvim_create_autocmd("User", { group = group, pattern = "SnacksDashboardUpdatePost", callback = vim.schedule_wrap(find_card) })
   vim.api.nvim_create_autocmd("User", { group = group, pattern = "SnacksDashboardClosed", callback = function() card = nil end })
   -- drop resets its colours on a colorscheme change; remake the copies
   vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = function() made = {} end })
   -- drop loads after the dashboard's first draw
   vim.schedule(find_card)

   local show = Drop.show
   function Drop:show()
      local base = self.hl_group:gsub("Card$", "")
      local row, width = math.floor(self.row), vim.fn.strwidth(self.symbol)
      local over = card and row >= card.top and row <= card.bottom
         and self.col <= card.right and self.col + width - 1 >= card.left
      if over and not made[base] then
         local hl = vim.api.nvim_get_hl(0, { name = base, link = false })
         hl.bg = vim.api.nvim_get_hl(0, { name = "SnacksDashboardQuoteCard", link = false }).bg
         vim.api.nvim_set_hl(0, base .. "Card", hl)
         made[base] = true
      end
      self.hl_group = over and (base .. "Card") or base
      return show(self)
   end
end

-- No leaves in buffers marked with vim.b.no_drop (<leader>ud): drop starts
-- them through drop.drop.show, both on the dashboard and for the idle
-- screensaver, so that skips them for whichever buffer is current then.
local function skip_marked_buffers()
   local drop = require("drop.drop")
   local show = drop.show
   drop.show = function(...)
      if vim.b.no_drop then return end
      -- (leaves stay behind the bonsai: putting drop's see-through window
      -- above the bonsai's terminal float, or making the bonsai see-through,
      -- blanks out whatever is under it instead of blending)
      return show(...)
   end
end

return {
   "folke/drop.nvim",
   event = "VeryLazy",
   keys = {
      {
         "<leader>ud",
         function()
            vim.b.no_drop = not vim.b.no_drop or nil
            if vim.b.no_drop then
               require("drop").hide()
            elseif vim.bo.filetype == "snacks_dashboard" then
               -- the dashboard has leaves all the time, not just when idle
               require("drop").show()
            end
            vim.notify("Falling leaves " .. (vim.b.no_drop and "off" or "on") .. " in this buffer", vim.log.levels.INFO, { title = "drop" })
         end,
         desc = "Toggle falling leaves (this buffer)",
      },
   },
   opts = {
      filetypes = { "snacks_dashboard" },
      max = 25,
      winblend = 100,
   },
   config = function(_, opts)
      require("drop").setup(opts)
      card_background()
      skip_marked_buffers()
   end,
}
