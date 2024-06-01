local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("..config.custom_beautiful")

local TIME_OUT = 5

local battery_nerd_icons = {
  battery_0 = "\u{f008e}",
  battery_10 = "\u{f007a}",
  battery_20 = "\u{f007b}",
  battery_30 = "\u{f007c}",
  battery_40 = "\u{f007d}",
  battery_50 = "\u{f007e}",
  battery_60 = "\u{f007f}",
  battery_70 = "\u{f0080}",
  battery_80 = "\u{f0081}",
  battery_90 = "\u{f0082}",
  battery_100 = "\u{f0079}",
}

local battery_textbox = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font,
}

local font_for_icon = beautiful.font
if beautiful.font_family then
  font_for_icon = beautiful.font_family .. " " .."12"
end

local battery_icon = wibox.widget {
  widget = wibox.widget.textbox,
  font = font_for_icon,
}

local battery_container = wibox.widget {
  battery_icon,
  top = -2,
  widget = wibox.container.margin
}

local battery_widget = wibox.widget {
  {
    battery_container,
    battery_textbox,
    layout = wibox.layout.fixed.horizontal,
    spacing = 3,
  },
  left = 5,
  right = 5,
  widget = wibox.container.margin
}

local function get_battery_markup(battery_percentage, charging_status)
  local battery_percentage_number = tonumber(battery_percentage)
  local percentage_tens = math.floor(battery_percentage_number / 10) * 10
  local battery_icon_code = battery_nerd_icons["battery_" .. percentage_tens]
  local bolt_markup = ""
  if charging_status == "charging" then
    bolt_markup = '<span>\u{f140b}</span>'
  end
  return '<span>' .. battery_icon_code .. '</span>' .. bolt_markup
end

local function update_battery_widget(
    battery_textbox_widget,
    battery_icon_widget,
    stdout
)
  local battery_percentage = stdout:match("(%d?%d?%d)%%")
  local charging_status = stdout:match("Discharging") and "discharging" or "charging"

  if battery_percentage then
    battery_icon_widget.markup = get_battery_markup(battery_percentage, charging_status)
    battery_textbox_widget.text = battery_percentage .. "% "
  else
    battery_textbox_widget.text = "N/A"
  end
end

awful.widget.watch("acpi -b", TIME_OUT, function(widget, stdout)
  update_battery_widget(
    battery_textbox,
    battery_icon,
    stdout
  )
end)

return battery_widget
