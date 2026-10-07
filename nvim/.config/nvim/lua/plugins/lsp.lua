return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- Preserve every language previously supplied by CoC extensions.
    local servers = {
      "ansiblels", "bashls", "cssls", "dockerls", "gopls", "html",
      "intelephense", "jsonls", "lua_ls", "nginx_language_server", "pyright",
      "ts_ls",
    }
    -- rustup supplies an analyzer matched to the selected Rust toolchain.
    local rustup = vim.fn.exepath("rustup")
    if rustup ~= "" then
      vim.lsp.config("rust_analyzer", {
        cmd = { vim.fs.joinpath(vim.fs.dirname(rustup), "rust-analyzer") },
      })
      vim.lsp.enable("rust_analyzer")
    else
      table.insert(servers, "rust_analyzer")
    end
    -- LuaJIT plus nvim's own runtime, so `vim` and its API resolve in this config.
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        },
      },
    })
    vim.lsp.config("pyright", {
      settings = { python = { analysis = { typeCheckingMode = "standard" } } },
    })
    vim.lsp.config("html", {
      filetypes = { "html", "mustache", "handlebars" },
      init_options = { provideFormatter = true, embeddedLanguages = { css = true, javascript = true } },
    })
    local ansible_bin = vim.fn.stdpath("data") .. "/mason/packages/ansible-lint/venv/bin/"
    vim.lsp.config("ansiblels", {
      settings = {
        ansible = {
          python = { interpreterPath = ansible_bin .. "python" },
          ansible = { path = ansible_bin .. "ansible" },
          validation = { lint = { path = "ansible-lint" } },
        },
      },
    })
    local registry = require("mason-registry")
    registry.refresh(function()
      local pkg = registry.get_package("ansible-lint")
      if not pkg:is_installed() and not pkg:is_installing() then pkg:install() end
    end)
    require("mason-lspconfig").setup({
      ensure_installed = servers,
      -- Roslyn is managed by roslyn.nvim, not mason-lspconfig.
      automatic_enable = servers,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("native-lsp-keymaps", { clear = true }),
      callback = function(args)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gr", vim.lsp.buf.references, "References")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
        map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
      end,
    })
    -- Diagnostics remain available even before a language server attaches.
    vim.keymap.set("n", "[g", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
    vim.keymap.set("n", "]g", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
    vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
  end,
}
