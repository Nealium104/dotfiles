return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI panels: scopes, breakpoints, watches, call stack, REPL
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      -- Inline virtual text showing variable values next to your code
      "theHamsta/nvim-dap-virtual-text",
      -- Installs the debug adapter binary (vscode-php-debug) and wires it up
      { "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1. Install + register the PHP adapter via Mason.
      --    `handlers = {}` lets mason-nvim-dap apply its default setup for
      --    everything in `ensure_installed`, which creates `dap.adapters.php`
      --    pointing at the installed vscode-php-debug. Run :Mason to watch it
      --    install on first launch (or :MasonInstall php-debug-adapter).
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "php" },
        automatic_installation = true,
        handlers = {},
      })

      -- 2. Tell DAP how to start a PHP debug session.
      --    "launch" here means "listen for an incoming Xdebug connection".
      --    Xdebug 3 connects to port 9003 by default.
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          -- If your code runs in Docker/a VM/a remote host, map the path the
          -- server sees to your local checkout, e.g.:
          -- pathMappings = { ["/var/www/html"] = "${workspaceFolder}" },
        },
      }

      -- 3. UI: panels + inline values.
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Open the UI automatically when a session starts, close it when it ends.
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- A clearer breakpoint marker in the sign column.
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })

      -- 4. Keymaps. Function keys = stepping; <leader>d… = everything else.
      local map = vim.keymap.set
      map("n", "<F5>",  function() dap.continue() end,  { desc = "DAP: Continue / Start" })
      map("n", "<F10>", function() dap.step_over() end, { desc = "DAP: Step Over" })
      map("n", "<F11>", function() dap.step_into() end, { desc = "DAP: Step Into" })
      map("n", "<F12>", function() dap.step_out() end,  { desc = "DAP: Step Out" })
      map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
      map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional breakpoint" })
      map("n", "<leader>dc", function() dap.continue() end,  { desc = "Continue / Start" })
      map("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate session" })
      map("n", "<leader>dr", function() dap.repl.open() end, { desc = "Open REPL" })
      map("n", "<leader>du", function() dapui.toggle() end,  { desc = "Toggle DAP UI" })
    end,
  },
}
