local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- WSL
config.wsl_domains = {
    {
        name = 'WSL:Ubuntu',
        distribution = 'Ubuntu',
        default_cwd = '~',
    },
}
config.default_domain = 'WSL:Ubuntu'
config.automatically_reload_config = true

-- window
config.color_scheme = 'Catppuccin Macchiato'
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 1
config.win32_system_backdrop = 'Acrylic'
config.win32_acrylic_accent_color = "#303446"
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.colors = {
    visual_bell = '#313d4e'
}
config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 50,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 50
}

-- text
config.font = wezterm.font('Hasklug Nerd Font Mono')
config.font_size = 14

-- event handlers
wezterm.on("high-opacity", function(window, _)
    local overrides = window:get_config_overrides() or {}
    overrides.window_background_opacity = .25
    overrides.win32_system_backdrop = 'Disable'
    window:set_config_overrides(overrides)
end)

wezterm.on("low-opacity", function(window, _)
    local overrides = window:get_config_overrides() or {}
    overrides.window_background_opacity = 0
    overrides.win32_system_backdrop = 'Acrylic'
    window:set_config_overrides(overrides)
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
        mods = 'ALT|CTRL',
        action = act.EmitEvent "high-opacity"
    },
    {
        key = 'k',
        mods = 'ALT|CTRL',
        action = act.EmitEvent "low-opacity"
    },
    {
        key = 't',
        mods = 'CTRL',
        action = act.SpawnCommandInNewTab {
            domain = { DomainName = 'local' },
            args = { 'powershell.exe' },
        },
    },
}

return config
