local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("config.custom_beautiful")
local logger = require("utils.logger")

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local tasklist_widget = function(s)

  local sizes = {
    low_bar = 3,
  }

  return awful.widget.tasklist {
    screen          = s,
    filter          = awful.widget.tasklist.filter.currenttags,
    source  = function()
      -- Get the list of all clients
      local clients = awful.widget.tasklist.source.all_clients(
        s,
        awful.widget.tasklist.filter.currenttags
      )
      -- Reverse the list of clients
      local reversed_clients = {}
      for i = #clients, 1, -1 do
        table.insert(reversed_clients, clients[i])
      end
      return reversed_clients
    end,
    buttons         = tasklist_buttons,
    layout          = {
      spacing_widget = {
        {
          forced_height = 10,
          thickness     = 2,
          color         = beautiful.bg_focus,
          widget        = wibox.widget.separator,
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place,
      },
      spacing        = 5,
      layout         = wibox.layout.fixed.horizontal
    },
    widget_template = {
      {
        {
          {
            {
              id            = 'icon_role',
              widget        = wibox.widget.imagebox,
            },
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
          },
          {
            wibox.widget.base.make_widget(),
            id     = 'background_role',
            bg     = beautiful.fg_normal,
            widget = wibox.container.background,
            forced_height = sizes.low_bar,
          },
          spacing = 2,
          forced_num_cols = 1,
          forced_num_rows = 2,
          homogeneous     = false,
          expand          = true,
          layout = wibox.layout.grid,
        },
        top = sizes.low_bar,
        widget  = wibox.container.margin,
      },
      top = 2,
      bottom = 2,
      widget  = wibox.container.margin,
    },
  }
end

return tasklist_widget
