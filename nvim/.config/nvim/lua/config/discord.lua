local M = {}

-- Share one relay across Neovim instances, protected by flock.
function M.setup(opts)
  if vim.fn.has("wsl") ~= 1 then return end
  local relay = vim.fn.stdpath("data") .. "/cord/bin/npiperelay.exe"
  if vim.fn.executable(relay) ~= 1 or vim.fn.executable("socat") ~= 1 or vim.fn.executable("flock") ~= 1 then
    vim.notify("Cord on WSL needs socat, flock, and " .. relay, vim.log.levels.WARN)
    return
  end
  local runtime = vim.env.XDG_RUNTIME_DIR or ("/tmp/cord-" .. vim.uv.getuid())
  vim.fn.mkdir(runtime, "p", 448)
  local socket = runtime .. "/cord-discord-ipc-0"
  vim.fn.jobstart({
    "flock", "-n", runtime .. "/cord-discord.lock",
    "socat", "UNIX-LISTEN:" .. socket .. ",fork,unlink-early,mode=600",
    "EXEC:" .. relay .. " //./pipe/discord-ipc-0",
  }, { detach = true })
  opts.advanced = opts.advanced or {}
  opts.advanced.discord = opts.advanced.discord or {}
  opts.advanced.discord.pipe_paths = { socket }
  opts.advanced.discord.reconnect = { enabled = true, initial = true, interval = 5000 }
end

return M
