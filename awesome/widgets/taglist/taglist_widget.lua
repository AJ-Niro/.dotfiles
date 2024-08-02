local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("config.custom_beautiful")

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
    screen          = s,
    filter          = awful.widget.taglist.filter.all,
    buttons         = taglist_buttons,
    style           = {
      shape = gears.shape.rounded_rect,
    },
    layout          = {
      spacing = 5,
      layout  = wibox.layout.fixed.horizontal
    },
    widget_template = {
      {
        {
          id     = 'index_role',
          widget = wibox.widget.textbox,
          markup = '',
        },
        id                 = "index_bg",
        widget             = wibox.container.background,
        bg                 = beautiful.bg_normal,
        shape              = gears.shape.circle,
        shape_border_width = 6,
        shape_border_color = beautiful.bg_normal,
      },
      widget             = wibox.container.background,
      bg                 = beautiful.bg_normal,
      shape              = gears.shape.circle,
      shape_border_width = 3,
      shape_border_color = beautiful.fg_normal,
      shape_clip         = true,
      forced_height      = beautiful.font_size * 2,
      forced_width       = beautiful.font_size * 2,

      create_callback    = function(self, current_tag)
        local index_bg = self:get_children_by_id('index_bg')
        if current_tag.selected then
          index_bg[1].bg = beautiful.fg_normal
        else
          index_bg[1].bg = beautiful.bg_normal
        end
      end,
      update_callback    = function(self, current_tag)
        local index_bg = self:get_children_by_id('index_bg')
        if current_tag.selected then
          index_bg[1].bg = beautiful.fg_normal
        else
          index_bg[1].bg = beautiful.bg_normal
        end
      end,
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
