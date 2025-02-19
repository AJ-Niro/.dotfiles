local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("config.custom_beautiful")
local logger = require("utils.logger")

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

local create_tag_widget = function(s, tag_index)
  return awful.widget.taglist {
    screen          = s,
    filter          = function(t) return t.index == tag_index end,
    buttons         = taglist_buttons,
    style           = {
      shape = gears.shape.rounded_rect,
    },
    widget_template = {
      {
        {
          widget = wibox.widget.textbox,
          markup = '',
        },
        id                 = "dot_widget",
        widget             = wibox.container.background,
        bg                 = beautiful.color_transparent,
        shape              = gears.shape.circle,
        shape_border_width = 12,
        shape_border_color = beautiful.color_transparent,
      },
      widget             = wibox.container.background,
      bg                 = beautiful.color_transparent,
      shape              = gears.shape.circle,
      shape_border_width = 3,
      shape_border_color = beautiful.fg_normal,
      shape_clip         = true,
      forced_height      = beautiful.font_size + 8,
      forced_width       = beautiful.font_size + 8,

      create_callback    = function(self, current_tag)
        local dot_widget = self:get_children_by_id('dot_widget')

        if current_tag.selected then
          dot_widget[1].bg = beautiful.fg_normal
          return
        end

        local tag_have_clients = #current_tag:clients() > 0
        if tag_have_clients then
          dot_widget[1].bg = beautiful.fg_normal
          dot_widget[1].shape_border_width = 17
          return
        end

        dot_widget[1].bg = beautiful.color_transparent
      end,

      update_callback    = function(self, current_tag)
        local dot_widget = self:get_children_by_id('dot_widget')

        if current_tag.selected then
          dot_widget[1].bg = beautiful.fg_normal
          dot_widget[1].shape_border_width = 12
          return
        end

        local tag_have_clients = #current_tag:clients() > 0
        if tag_have_clients then
          dot_widget[1].shape_border_width = 17
          return
        end

        dot_widget[1].bg = beautiful.color_transparent
      end,
    },
  }
end

local font_for_icon = beautiful.font 
if beautiful.font_family then
  font_for_icon = beautiful.font_family .. " " ..  (beautiful.font_size + 6)
end


local middle_icon = wibox.widget {
  widget       = wibox.widget.textbox,
  font         = font_for_icon,
  markup       = "<span>\u{f09fe}</span>",
  forced_width =  beautiful.font_size + 3,
}

local middle_icon_margin = wibox.widget {
  middle_icon,
  top = -2,
  right = 5,
  left = 5,
  widget = wibox.container.margin
}

local taglist_widget = function(s)
  local tags_layout = wibox.layout.fixed.horizontal()
  tags_layout.fill_space = true
  tags_layout.spacing = 3
  for i = 1, 8 do
    if i == 5 then -- Add Middle Icon
      tags_layout:add(middle_icon_margin)
    end
    local tag_widget = create_tag_widget(s, i)
    tags_layout:add(tag_widget)
  end

  local taglist_placer = wibox.widget {
    tags_layout,
    halign = "center",
    valign = "center",
    layout = wibox.container.place,
  }

  return taglist_placer
end

return taglist_widget
