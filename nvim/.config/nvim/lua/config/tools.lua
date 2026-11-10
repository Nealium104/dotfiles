-- Everything Neovim installs for itself, in one place. Read by the plugin specs
-- (lsp.lua, treesitter.lua) and by config/bootstrap.lua, which `make install`
-- runs headless so a fresh machine is ready before nvim is first opened.
--
-- Command-line tools (ruff, shfmt, prettier, hadolint, yamllint, ...) are not
-- here: the dotfiles Ansible setup installs those system-wide.
return {
   -- lspconfig names, installed through mason (rust_analyzer comes from rustup).
   lsp_servers = {
      "ansiblels",
      "basedpyright",
      "bashls",
      "cssls",
      "dockerls",
      "gopls",
      "html",
      "intelephense",
      "jsonls",
      "lua_ls",
      "nginx_language_server",
      "sqlls",
      "ts_ls",
      "yamlls",
   },

   -- Other mason packages, by mason name.
   mason_packages = {
      "ansible-lint", -- ansiblels runs it
      "php-debug-adapter", -- dap.lua (mason-nvim-dap "php")
      "roslyn-language-server", -- roslyn.nvim
   },

   -- Treesitter parsers.
   parsers = {
      "c", "c_sharp", "lua", "vim", "vimdoc", "query", "markdown",
      "markdown_inline", "javascript", "go", "rust", "php", "typescript",
      "xml", "yaml", "python", "perl", "json", "jsdoc", "phpdoc", "html",
      "bash", "css", "sql", "dockerfile", "tsx",
      -- git buffers (fugitive status, commits, interactive rebase)
      "gitcommit", "git_rebase", "diff",
   },
}
