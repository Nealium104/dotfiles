return {
   "mfussenegger/nvim-lint",
   event = { "BufReadPost", "BufNewFile" },
   -- Linters for filetypes whose language server doesn't cover them (hadolint,
   -- yamllint). The tools come from the dotfiles Ansible setup. ruff and
   -- shellcheck lint through their language servers, not through this plugin.
   config = function()
      local lint = require("lint")
      -- From config/languages.lua.
      lint.linters_by_ft = vim.deepcopy(require("config.tools").linters_by_ft)

      local function run_lint()
         -- Skip quietly when a tool isn't installed yet
         local names = vim.tbl_filter(function(name)
            local cmd = lint.linters[name].cmd
            return vim.fn.executable(type(cmd) == "function" and cmd() or cmd) == 1
         end, lint.linters_by_ft[vim.bo.filetype] or {})
         if #names > 0 then lint.try_lint(names) end
      end

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
         group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
         callback = run_lint,
      })
      vim.schedule(run_lint)
   end,
}
