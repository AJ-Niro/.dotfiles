-- Require necessary libraries
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("..config.custom_beautiful")

local volume_widget = {}

local volume_nerd_icons = {
  low = "\u{f026}",
  medium = "\u{f027}",
  high = "\u{f028}",
  mute = "\u{eee8}",
}

local font_for_icon = beautiful.font 
if beautiful.font_family then
  font_for_icon = beautiful.font_family .. " " ..  (beautiful.font_size + 2)
end

local volume_icon_widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = font_for_icon,
  markup = '<span>' .. volume_nerd_icons.medium .. '</span>'
}

local volume_textbox_widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font,
}

-- Function to update the volume widget
function volume_widget.update()
  awful.spawn.easy_async_with_shell('echo "$(pamixer --get-volume)-$(pamixer --get-mute)"', function(stdout)
    local volume, mute_status = stdout:match("^(%d+)-(%a+)")

    if mute_status == "true" then
      volume_icon_widget.markup = '<span>' .. volume_nerd_icons.mute .. '</span>'
      volume_textbox_widget.text = " Mute "
    else
      volume = tonumber(volume)
      if volume == 0 then
        volume_icon_widget.markup = '<span>' .. volume_nerd_icons.mute .. '</span>'
      elseif volume <= 33 then
        volume_icon_widget.markup = '<span>' .. volume_nerd_icons.low .. '</span>'
      elseif volume <= 66 then
        volume_icon_widget.markup = '<span>' .. volume_nerd_icons.medium .. '</span>'
      else
        volume_icon_widget.markup = '<span>' .. volume_nerd_icons.high .. '</span>'
      end
      volume_textbox_widget.text = " " .. volume .. "% "
    end
  end)
end

function volume_widget.increase()
  awful.spawn("pamixer --increase 5")
  volume_widget.update()
end

function volume_widget.decrease()
  awful.spawn("pamixer --decrease 5")
  volume_widget.update()
end

function volume_widget.mute()
  awful.spawn.easy_async_with_shell("pamixer --get-mute", function(stdout)
    local mute_state = stdout:gsub("%s+", "")
    if mute_state == "true" then
      awful.spawn("pamixer --unmute")
    else
      awful.spawn("pamixer --mute")
    end
    volume_widget.update()
  end)
end

function volume_widget.get_widget()
  return wibox.widget {
    {
      volume_icon_widget,
      volume_textbox_widget,
      layout = wibox.layout.fixed.horizontal,
      spacing = -5,
    },
    left = 5,
    right = 0,
    widget = wibox.container.margin
  }
end

-- Call update function to initialize the widget with the current volume
volume_widget.update()

return volume_widget
