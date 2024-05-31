local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("..config.custom_beautiful")

-- Create the textbox widget for battery status
local battery_textbox = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font, -- Use the font from the theme
}

-- Create a container for the battery widget with padding
local battery_widget = wibox.widget {
  battery_textbox,
  left = 10,
  right = 10,
  top = 5,
  bottom = 5,
  widget = wibox.container.margin
}

-- Function to update battery status
local function update_battery_widget(widget, stdout)
  local battery_percentage = stdout:match("(%d?%d?%d)%%")
  local charging_status = stdout:match("Discharging") and "" or "(Charging)"

  if battery_percentage then
    widget.text = "Battery: " .. battery_percentage .. "% " .. charging_status
  else
    widget.text = "Battery: N/A"
  end
end

-- Use awful.widget.watch to periodically update the textbox widget
awful.widget.watch("acpi -b", 10, function(widget, stdout)
  update_battery_widget(battery_textbox, stdout)
end)

return battery_widget
