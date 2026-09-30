-- Install at C:\Users\nagr225\.wezterm.lua (or its existing symlink target).
-- Keep the actual configuration in WSL.
local wezterm = require 'wezterm'
local config_path = [[\\wsl.localhost\Ubuntu\home\neal\dotfiles\wezterm\.config\wezterm\wezterm.lua]]

wezterm.add_to_config_reload_watch_list(config_path)
return dofile(config_path)
