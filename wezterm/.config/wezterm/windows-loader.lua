-- Copy to %USERPROFILE%\.wezterm.lua on Windows.
-- Keep the actual configuration in WSL. The WSL username differs between
-- machines, so find the dotfiles checkout instead of hardcoding it.
local wezterm = require 'wezterm'
local matches = wezterm.glob([[\\wsl.localhost\Ubuntu\home\*\dotfiles\wezterm\.config\wezterm\wezterm.lua]])
local config_path = matches[1]
if not config_path then
  wezterm.log_error('windows-loader: no dotfiles checkout found under \\\\wsl.localhost\\Ubuntu\\home')
  return {}
end

wezterm.add_to_config_reload_watch_list(config_path)
return dofile(config_path)
