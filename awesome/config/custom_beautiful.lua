local custom_beautiful = require("beautiful")

local home_path = os.getenv("HOME")

custom_beautiful.init(home_path .. "/.dotfiles/awesome/config/theme.lua")

custom_beautiful.get().wallpaper = home_path .. "/.dotfiles/wallpapers/Deep_Purple.jpg"

return custom_beautiful