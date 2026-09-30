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
      formatters_by_ft = {
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
      },
      formatters = {
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
