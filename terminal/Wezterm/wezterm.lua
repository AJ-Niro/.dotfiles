local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.font = wezterm.font 'Hack Nerd Font'

config.colors = {
    -- The default text color
    foreground = 'rgb(223, 223, 223)',

    -- The default background color
    background = 'rgb(26, 26, 26)',

    -- Make the selection text color fully transparent.
    selection_fg = 'none',

    -- Set the selection background color with alpha.
    selection_bg = 'rgba(50% 50% 50% 50%)',
}
  

return config