local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'wsl.exe', '--cd', '~' }

config.font_size = 14
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0
config.win32_system_backdrop = 'Acrylic'
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- config.colors = {
-- 	tab_bar = {
-- 		background = "#202020"
-- 	}
-- }
config.font = wezterm.font('CaskaydiaCove Nerd Font Mono')

-- event handlers
wezterm.on("high-opacity", function(window, _)
	local opacity = .25
	window:set_config_overrides({
		window_background_opacity = opacity,
		win32_system_backdrop = 'Disable'
	})
end)

wezterm.on("low-opacity", function(window, _)
	local opacity = 0
	window:set_config_overrides({
		window_background_opacity = opacity,
		win32_system_backdrop = 'Acrylic'
	})
end)

-- Keybinds
local act = wezterm.action
config.keys = {
	{
		key = 'v',
		mods = 'CTRL',
		action = act.PasteFrom 'Clipboard'
	},
	{
		key = 'j',
		mods = 'ALT',
		action = act.EmitEvent "high-opacity"
	},
	{
		key = 'h',
		mods = 'ALT',
		action = act.EmitEvent "low-opacity"
	},
}

return config
