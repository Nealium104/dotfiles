return {
   "neovim/nvim-lspconfig",
   -- Load with the first file instead of at startup (this also pulls in mason,
   -- which refreshes its registry). BufReadPre runs before FileType, so servers
   -- still attach to that first file.
   event = { "BufReadPre", "BufNewFile" },
   dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
   },
   config = function()
      vim.lsp.config("*", {
         capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- The list lives in config/tools.lua, shared with `make install`.
      local servers = vim.deepcopy(require("config.tools").lsp_servers)

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
               -- arrayIndex: no [1]/[01] labels on list entries (noisy in plugin specs)
               hint = { enable = true, arrayIndex = "Disable" },
            },
         },
      })

      -- Inlay hints
      vim.lsp.config("gopls", {
         settings = {
            gopls = {
               hints = {
                  assignVariableTypes = true,
                  compositeLiteralFields = true,
                  constantValues = true,
                  functionTypeParameters = true,
                  parameterNames = true,
                  rangeVariableTypes = true,
               },
            },
         },
      })
      local ts_hints = {
         includeInlayParameterNameHints = "literals",
         includeInlayFunctionParameterTypeHints = true,
         includeInlayVariableTypeHints = true,
         includeInlayPropertyDeclarationTypeHints = true,
         includeInlayFunctionLikeReturnTypeHints = true,
         includeInlayEnumMemberValueHints = true,
      }
      vim.lsp.config("ts_ls", {
         settings = {
            typescript = { inlayHints = ts_hints },
            javascript = { inlayHints = ts_hints },
         },
      })
      -- basedpyright: pyright plus inlay hints
      vim.lsp.config("basedpyright", {
         settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })
      -- ruff's language server: lint diagnostics and quick fixes for Python.
      -- Hover stays with basedpyright.
      vim.lsp.config("ruff", {
         on_attach = function(client) client.server_capabilities.hoverProvider = false end,
      })
      -- Servers whose binary the dotfiles Ansible setup installs (`system` in
      -- config/languages.lua): enabled here, never installed by mason.
      for _, server in ipairs(require("config.tools").system_servers) do
         vim.lsp.enable(server)
      end
      vim.lsp.config("html", {
         filetypes = { "html", "mustache", "handlebars" },
         init_options = {
            provideFormatter = true,
            embeddedLanguages = { css = true, javascript = true },
         },
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
            map("K", vim.lsp.buf.hover, "Hover documentation")
            map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
            map("<leader>ca", vim.lsp.buf.code_action, "Code action")
            map("<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
            map("<leader>cS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Workspace symbols")

            -- Show inlay hints when supported (toggle: <leader>ui).
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client:supports_method("textDocument/inlayHint") then
               vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
            end
         end,
      })
      vim.keymap.set("n", "<leader>ui", function()
         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      end, { desc = "Toggle inlay hints" })
      -- Diagnostics remain available even before a language server attaches.
      vim.keymap.set(
         "n",
         "[g",
         function() vim.diagnostic.jump({ count = -1, float = true }) end,
         { desc = "Previous diagnostic" }
      )
      vim.keymap.set(
         "n",
         "]g",
         function() vim.diagnostic.jump({ count = 1, float = true }) end,
         { desc = "Next diagnostic" }
      )
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
   end,
}
