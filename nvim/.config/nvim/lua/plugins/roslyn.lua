return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    -- Roslyn is a NATIVE vim.lsp client, separate from coc.nvim (which handles
    -- your other languages). The server binary is installed through Mason --
    -- the same Mason we added for nvim-dap. Install once with
    -- `:MasonInstall roslyn-language-server`; roslyn.nvim then auto-detects the
    -- `roslyn-language-server` shim in $MASON/bin. Requires the .NET SDK on PATH.
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Optional Roslyn settings, e.g. inlay hints / code lens:
      -- settings = {
      --   ["csharp|inlay_hints"] = { csharp_enable_inlay_hints_for_implicit_var_types = true },
      --   ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
      -- },
    },
    config = function(_, opts)
      require("roslyn").setup(opts)

      -- Roslyn talks to native LSP, so coc's global keymaps/completion don't
      -- apply to C#. Wire up C#-only, buffer-local equivalents on attach.
      -- (Buffer-local maps win over coc's global gd/gr/K/<leader>f in .cs files,
      -- and leave every other filetype on coc untouched.)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("roslyn-lsp-attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "roslyn" then
            return
          end
          local bufnr = args.buf
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gy", vim.lsp.buf.type_definition, "Go to type definition")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
          map("[g", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
          map("]g", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

          -- Built-in LSP autocompletion (Neovim 0.11+) -- no nvim-cmp needed.
          -- In .cs buffers: navigate with <C-n>/<C-p>, accept with <C-y>.
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
          end
        end,
      })
    end,
  },
}
