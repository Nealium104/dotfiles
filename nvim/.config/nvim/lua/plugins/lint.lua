return {
   "mfussenegger/nvim-lint",
   event = { "BufReadPost", "BufNewFile" },
   -- Linters for filetypes whose language server doesn't cover them.
   -- Language servers installed from Ansible go through nvim-lint.
   config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
         dockerfile = { "hadolint" },
         -- Plain YAML and compose files only: ansiblels already runs ansible-lint,
         -- which includes the yamllint rules, on yaml.ansible buffers.
         yaml = { "yamllint" },
      }

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
