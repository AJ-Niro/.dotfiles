local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local home_path = os.getenv("HOME")
beautiful.init(home_path .. "/.dotfiles/awesome/config/theme.lua")

-- Function to get battery status
local function get_battery_status()
  local fd = io.popen("acpi -b")
  local status = fd:read("*all")
  fd:close()

  local battery_percentage = status:match("(%d?%d?%d)%%")

  if battery_percentage then
    return battery_percentage .. "%"
  else
    return "N/A"
  end
end

-- Create the battery widget with theme font and padding
local battery_widget = wibox.widget {
  {
    widget = wibox.widget.textbox,
    text = "Battery: " .. get_battery_status(),
    font = beautiful.font,     -- Use the font from the theme
  },
  left = 10,
  right = 10,
  top = 5,
  bottom = 5,
  widget = wibox.container.margin
}

-- Update the battery widget every 60 seconds
gears.timer {
  timeout = 60,
  autostart = true,
  callback = function()
    battery_widget.text = "Battery: " .. get_battery_status()
  end
}

return battery_widget
