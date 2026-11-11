-- Installs everything in config/tools.lua without opening the editor. Run by
-- the dotfiles Ansible setup (`make install`), after `Lazy! restore`:
--
--   nvim --headless -c "lua require('config.bootstrap').run({ upgrade = false })"
--
-- Only missing tools are installed; `upgrade = true` also updates the parsers.
-- Prints "bootstrap: installed <n>" so Ansible can tell whether anything changed.
-- Exits non-zero if an install fails.
local M = {}

-- An error in a -c command doesn't end a headless nvim: it prints the error and
-- then waits for input that never comes, so Ansible would wait forever. Any
-- error in the wrapped function exits with code 1 instead.
local function exit_on_error(fn)
   return function(opts)
      local ok, err = xpcall(fn, debug.traceback, opts)
      if not ok then
         io.stderr:write("bootstrap: " .. tostring(err) .. "\n")
         vim.cmd("cquit 1")
      end
   end
end

-- Plugins at the versions in lazy-lock.json (`upgrade = true`: latest, which
-- rewrites the lockfile). Prints "bootstrap: plugins changed <n>", counting
-- plugins that were cloned or moved to another commit; lazy's own output can't
-- tell a no-op restore from a real one.
M.plugins = exit_on_error(function(opts)
   opts = opts or {}
   local git = require("lazy.manage.git")
   local plugins = require("lazy.core.config").plugins
   local function commits()
      local ret = {}
      for name, plugin in pairs(plugins) do
         local info = vim.uv.fs_stat(plugin.dir) and git.info(plugin.dir)
         ret[name] = info and info.commit or false
      end
      return ret
   end
   local before = commits()
   local lazy = require("lazy")
   if opts.upgrade then
      lazy.sync({ wait = true, show = false })
   else
      lazy.restore({ wait = true, show = false })
   end
   local changed = 0
   for name, commit in pairs(commits()) do
      if commit ~= before[name] then changed = changed + 1 end
   end
   io.stdout:write(("bootstrap: plugins changed %d\n"):format(changed))
   vim.cmd("qall!")
end)

M.run = exit_on_error(function(opts)
   opts = opts or {}
   local tools = require("config.tools")
   local installed = 0

   -- Mason packages. mason-lspconfig skips ensure_installed when headless, so
   -- install directly; :MasonInstall blocks until done in headless mode.
   require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim" } })
   local registry = require("mason-registry")
   registry.refresh()
   local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package
   local missing = {}
   for _, server in ipairs(tools.lsp_servers) do
      local name = to_package[server] or server
      if not registry.is_installed(name) then table.insert(missing, name) end
   end
   for _, name in ipairs(tools.mason_packages) do
      if not registry.is_installed(name) then table.insert(missing, name) end
   end
   if #missing > 0 then
      -- a real failure quits nvim with code 1 from inside :MasonInstall. it can
      -- also throw after every install succeeded: mason echoes installer stderr
      -- (dotnet's progress, for one) as error messages, which vim.cmd raises.
      -- so its result is ignored and what actually got installed is checked below
      pcall(vim.cmd, "MasonInstall " .. table.concat(missing, " "))
      installed = installed + #missing
   end
   -- :MasonInstall skips (without waiting for) packages that the config itself
   -- already started installing at startup (lsp.lua's ansible-lint), so wait
   -- for those before quitting, or they'd be cut off half-installed.
   vim.wait(600000, function()
      for _, name in ipairs(missing) do
         if registry.get_package(name):is_installing() then return false end
      end
      return true
   end, 500)
   local failed = vim.tbl_filter(function(name) return not registry.is_installed(name) end, missing)
   if #failed > 0 then
      error("not installed (see ~/.local/state/nvim/mason.log): " .. table.concat(failed, " "), 0)
   end

   -- Treesitter parsers (nvim-treesitter's install() skips ones already present).
   require("lazy").load({ plugins = { "nvim-treesitter" } })
   local ts = require("nvim-treesitter")
   local before = #ts.get_installed()
   local ok = ts.install(tools.parsers):wait(600000)
   if opts.upgrade then ts.update():wait(600000) end
   installed = installed + (#ts.get_installed() - before)

   io.stdout:write(("bootstrap: installed %d\n"):format(installed))
   if ok == false then vim.cmd("cquit 1") end
   vim.cmd("qall!")
end)

return M
