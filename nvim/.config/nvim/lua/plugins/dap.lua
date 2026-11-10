return {
   {
      "mfussenegger/nvim-dap",
      dependencies = {
         -- UI panels
         { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
         -- Inline text showing variable values next to your code
         "theHamsta/nvim-dap-virtual-text",
         -- Installs debug adapter binary (vscode-php-debug)
         { "jay-babu/mason-nvim-dap.nvim", dependencies = { "mason-org/mason.nvim" } },
      },
      -- Loads on the first debug key instead of at startup: mason-nvim-dap's
      -- adapter mappings alone took ~500ms of a ~570ms startup.
      keys = {
         -- Function keys = stepping; <leader>d… = everything else.
         { "<F5>", function() require("dap").continue() end, desc = "DAP: Continue / Start" },
         { "<F10>", function() require("dap").step_over() end, desc = "DAP: Step Over" },
         { "<F11>", function() require("dap").step_into() end, desc = "DAP: Step Into" },
         { "<F12>", function() require("dap").step_out() end, desc = "DAP: Step Out" },
         { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
         {
            "<leader>dB",
            function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
            desc = "Conditional breakpoint",
         },
         { "<leader>dc", function() require("dap").continue() end, desc = "Continue / Start" },
         { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate session" },
         { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
         { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      },
      config = function()
         local dap = require("dap")
         local dapui = require("dapui")

         require("mason-nvim-dap").setup({
            ensure_installed = { "php" },
            automatic_installation = true,
            handlers = {},
         })

         -- Tell DAP how to start a PHP debug session.
         dap.configurations.php = {
            {
               type = "php",
               request = "launch",
               name = "Listen for Xdebug",
               -- Xdebug 3 connects to 9003
               port = 9003,
               -- For Docker/VM/remote host, map the path the server sees to local checkout
               -- pathMappings = { ["/var/www/html"] = "${workspaceFolder}" },
            },
         }

         dapui.setup()
         require("nvim-dap-virtual-text").setup()

         -- Open the UI automatically when a session starts, close it when it ends.
         dap.listeners.before.attach.dapui_config = function() dapui.open() end
         dap.listeners.before.launch.dapui_config = function() dapui.open() end
         dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
         dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

         -- A clearer breakpoint marker in the sign column.
         vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
      end,
   },
}
