local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'wsl.exe', '--cd', '~' }

config.font_size = 14
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.window_background_opacity = 0.65
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.colors = {
	tab_bar = {
		background = "#202020"
	}
}
config.font = wezterm.font('CaskaydiaCove Nerd Font Mono')

-- Keybinds
local act = wezterm.action
config.keys = {
	{
		key = 'v',
		mods = 'CTRL',
		action = act.PasteFrom 'Clipboard'
	},
}

return config
