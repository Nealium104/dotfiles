-- Every language this config supports, one entry each. The plugin specs build
-- their tables from here (see config/tools.lua for how), so adding or changing
-- a language usually means editing only this file.
--
-- Fields (all optional):
--   filetypes   the filetypes the rest of the entry applies to
--   servers     language servers (lspconfig names), installed by mason and enabled
--   system      language servers whose binary comes from the dotfiles Ansible setup;
--               only enabled here, never installed by mason
--   mason       other mason packages (debug adapters, servers set up by a plugin)
--   parsers     treesitter parsers
--   formatters  conform formatters, run in order by <leader>cf
--   linters     nvim-lint linters, for what the language server doesn't check
--   indent      width per level; `tabs = true` indents with real tabs at that width
--   needs       command-line tools the dotfiles Ansible setup must install for this
--               language (documentation only: Ansible can't read this file)
--
-- Server *settings* (inlay hints, type checking modes, ...) live in plugins/lsp.lua.
-- Special cases stay next to the code that needs them:
--   PHP formatting picks the project's vendored tool (plugins/conform.lua)
--   rust_analyzer comes from rustup when it's installed (plugins/lsp.lua)
--   compose files are plain yaml, matched by name for indent (config/filetypes.lua)
return {
   bash = {
      filetypes = { "sh" }, -- .bash files are detected as sh too
      servers = { "bashls" }, -- runs shellcheck for diagnostics
      parsers = { "bash" },
      formatters = { "shfmt" },
      indent = 4,
      needs = { "shellcheck (apt)", "shfmt (apt)" },
   },
   c = { parsers = { "c" } },
   csharp = {
      filetypes = { "cs" },
      mason = { "roslyn-language-server" }, -- started by roslyn.nvim, not lspconfig
      parsers = { "c_sharp" },
      indent = 4,
   },
   css = {
      filetypes = { "css" },
      servers = { "cssls" },
      parsers = { "css" },
      formatters = { "prettier" },
      indent = 2,
      needs = { "prettier (npm)" },
   },
   docker = {
      filetypes = { "dockerfile" },
      servers = { "dockerls" },
      parsers = { "dockerfile" },
      linters = { "hadolint" },
      indent = 2,
      needs = { "hadolint (release binary)" },
   },
   git = { parsers = { "gitcommit", "git_rebase", "diff" } }, -- fugitive buffers
   go = {
      filetypes = { "go" },
      servers = { "gopls" }, -- also formats
      parsers = { "go" },
      indent = 4,
      tabs = true,
      needs = { "go (release)" }, -- mason builds gopls with it
   },
   html = {
      filetypes = { "html" }, -- includes .mustache files (init.lua maps them to html)
      servers = { "html" },
      parsers = { "html" },
      formatters = { "prettier" },
      indent = 4,
      needs = { "prettier (npm)" },
   },
   javascript = {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      servers = { "ts_ls" },
      parsers = { "javascript", "typescript", "tsx", "jsdoc" },
      formatters = { "prettier" },
      indent = 2,
      needs = { "node (fnm)", "prettier (npm)" },
   },
   json = {
      filetypes = { "json" },
      servers = { "jsonls" },
      parsers = { "json" },
      formatters = { "prettier" },
      needs = { "prettier (npm)" },
   },
   lua = {
      filetypes = { "lua" },
      servers = { "lua_ls" }, -- also formats
      parsers = { "lua" },
      indent = 3,
   },
   markdown = { parsers = { "markdown", "markdown_inline" } },
   mustache = { filetypes = { "mustache" }, indent = 4 }, -- only when not mapped to html
   nginx = {
      filetypes = { "nginx" },
      servers = { "nginx_language_server" },
      indent = 4,
   },
   perl = { parsers = { "perl" } },
   php = {
      filetypes = { "php" },
      servers = { "intelephense" },
      mason = { "php-debug-adapter" }, -- nvim-dap (plugins/dap.lua)
      parsers = { "php", "phpdoc" },
      -- formatters: the project's own (vendor/bin), see plugins/conform.lua
      indent = 4,
      needs = { "php-cli (apt)", "php-xdebug (apt)" },
   },
   python = {
      filetypes = { "python" },
      servers = { "basedpyright" },
      system = { "ruff" }, -- lint diagnostics and quick fixes
      parsers = { "python" },
      formatters = { "ruff_organize_imports", "ruff_format" },
      indent = 4,
      needs = { "ruff (uv_tools)", "python3-venv (apt)" },
   },
   rust = {
      filetypes = { "rust" },
      -- rust_analyzer: from rustup, else mason (plugins/lsp.lua)
      parsers = { "rust" },
      indent = 4,
   },
   sql = {
      filetypes = { "sql" },
      servers = { "sqlls" },
      parsers = { "sql" },
      indent = 2,
   },
   vim = { parsers = { "vim", "vimdoc", "query" } }, -- help pages, treesitter queries
   xml = { parsers = { "xml" } },
   yaml = {
      -- Plain YAML and compose files. Ansible YAML is its own entry below.
      filetypes = { "yaml" },
      servers = { "yamlls" }, -- knows the compose schema
      parsers = { "yaml" },
      formatters = { "prettier" },
      linters = { "yamllint" },
      needs = { "prettier (npm)", "yamllint (apt)" },
   },
   yaml_ansible = {
      filetypes = { "yaml.ansible" },
      servers = { "ansiblels" }, -- runs ansible-lint, which includes the yamllint rules
      mason = { "ansible-lint" },
   },
}
