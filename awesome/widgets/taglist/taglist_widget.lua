local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local taglist_widget = function(s)

  local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
  )

  local local_taglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    style = {
      shape = gears.shape.rounded_bar,
    },
  }

  local taglist_container = wibox.widget {
    wibox.widget {
      local_taglist,
      forced_height = 22,
      layout = wibox.container.background,
    },
    halign = "center",
    valign = "center",
    layout = wibox.container.place,
  }

  return taglist_container
end

return taglist_widget
