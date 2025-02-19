local wibox = require("wibox")
local beautiful = require("..config.custom_beautiful")

local font_for_icon = beautiful.font 
if beautiful.font_family then
  font_for_icon = beautiful.font_family .. " " ..  (beautiful.font_size + 2)
end


local calendar_widget = wibox.widget.textclock(
  "<span font='" .. font_for_icon .. "'>\u{f00ee}</span>"
  ..
  " %a %d %b "
  ..
  "<span font='" .. font_for_icon .. "'>\u{f017}</span>"
  .. " %H:%M "
)

return calendar_widget
