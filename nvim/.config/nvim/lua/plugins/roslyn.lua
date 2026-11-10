return {
   "seblyng/roslyn.nvim",
   ft = "cs",
   dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
   -- Uses the shared native LSP keymaps and Blink completion capabilities.
   init = function()
      -- Roslyn sends no inlay hints unless these are on (shown/toggled in lsp.lua).
      vim.lsp.config("roslyn", {
         settings = {
            ["csharp|inlay_hints"] = {
               csharp_enable_inlay_hints_for_implicit_object_creation = true,
               csharp_enable_inlay_hints_for_implicit_variable_types = true,
               csharp_enable_inlay_hints_for_lambda_parameter_types = true,
               csharp_enable_inlay_hints_for_types = true,
               dotnet_enable_inlay_hints_for_indexer_parameters = true,
               dotnet_enable_inlay_hints_for_literal_parameters = true,
               dotnet_enable_inlay_hints_for_object_creation_parameters = true,
               dotnet_enable_inlay_hints_for_other_parameters = true,
               dotnet_enable_inlay_hints_for_parameters = true,
               dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
               dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            },
         },
      })
   end,
   opts = {},
}
