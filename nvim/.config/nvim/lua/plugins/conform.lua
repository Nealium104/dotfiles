return {
   "stevearc/conform.nvim",
   cmd = "ConformInfo",
   keys = {
      {
         "<leader>cf",
         function() require("conform").format({ async = true }) end,
         mode = { "n", "x" },
         desc = "Format buffer or selection",
      },
   },
   opts = function()
      local util = require("conform.util")
      return {
         default_format_opts = { lsp_format = "fallback" },
         -- From config/languages.lua (tools installed by the dotfiles Ansible setup),
         -- plus PHP, which picks the project's own tool.
         formatters_by_ft = vim.tbl_extend("force", vim.deepcopy(require("config.tools").formatters_by_ft), {
            php = function(bufnr)
               -- Use the project's own formatter/version, then fall back to Intelephense.
               for _, name in ipairs({ "php_cs_fixer", "phpcbf", "pint" }) do
                  local info = require("conform").get_formatter_info(name, bufnr)
                  if info.available and vim.fs.normalize(info.command):find("/vendor/bin/", 1, true) then
                     return { name }
                  end
               end
               return {}
            end,
         }),
         formatters = {
            -- Indent like the buffer (filetypes.lua), unless the project has its own .prettierrc.
            prettier = {
               prepend_args = function(_, ctx)
                  local args = { "--config-precedence", "prefer-file", "--tab-width", tostring(ctx.shiftwidth) }
                  if not vim.bo[ctx.buf].expandtab then table.insert(args, "--use-tabs") end
                  return args
               end,
            },
            pint = { cwd = util.root_file({ "pint.json", "composer.json" }) },
            php_cs_fixer = {
               cwd = util.root_file({ ".php-cs-fixer.php", ".php-cs-fixer.dist.php", "composer.json" }),
            },
            phpcbf = {
               cwd = util.root_file({ "phpcs.xml", ".phpcs.xml", "phpcs.xml.dist", ".phpcs.xml.dist", "composer.json" }),
            },
         },
      }
   end,
}
