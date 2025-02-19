-- Require necessary libraries
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("..config.custom_beautiful")

local brightness_widget = {}

local font_for_icon = beautiful.font 
if beautiful.font_family then
  font_for_icon = beautiful.font_family .. " " ..  (beautiful.font_size + 2)
end

local brightness_icon_widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = font_for_icon,
  markup = '<span>' .. "\u{f0244}" .. '</span>'
}

local brightness_textbox_widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font,
}

-- Function to update the brightness widget
function brightness_widget.update()
  awful.spawn.easy_async_with_shell("brightnessctl | grep 'Current brightness:' | cut -f2 -d '(' | cut -f1 -d '%'", function(stdout)
    local brightness = tonumber(stdout)
    brightness_textbox_widget.text = brightness .. "% "
  end)
end

function brightness_widget.increase()
  local brightness_text = brightness_textbox_widget.text
  local brightness_percentage_str = brightness_text:gsub("%%", "")
  local brightness_percentage = tonumber(brightness_percentage_str)
  local brightness = brightness_percentage + 5
  awful.spawn("brightnessctl set ".. brightness .."%")
  brightness_widget.update()
end

function brightness_widget.decrease()
  local brightness_text = brightness_textbox_widget.text
  local brightness_percentage_str = brightness_text:gsub("%%", "")
  local brightness_percentage = tonumber(brightness_percentage_str)
  local brightness = brightness_percentage - 5
  awful.spawn("brightnessctl set ".. brightness .."%")
  brightness_widget.update()
end

function brightness_widget.get_widget()
  return wibox.widget {
    {
      brightness_icon_widget,
      brightness_textbox_widget,
      layout = wibox.layout.fixed.horizontal,
      spacing = 5,
    },
    left = 5,
    right = 0,
    widget = wibox.container.margin
  }
end

-- Call update function to initialize the widget with the current brightness
brightness_widget.update()

return brightness_widget
