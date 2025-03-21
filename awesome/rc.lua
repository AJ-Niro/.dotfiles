-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("config.custom_beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Custom widgets
local battery_widget = require("widgets.battery.battery_widget")
local volume_widget = require("widgets.volume.volume_widget")
local brightness_widget = require("widgets.brightness.brightness_widget")
local calendar_widget = require("widgets.calendar.calendar_widget")
local taglist_widget = require("widgets.taglist.taglist_widget")
local tasklist_widget = require("widgets.tasklist.tasklist_widget")
-- Configurations
local tag_names = { "a", "s", "d", "f", "j", "k", "l", ";" }

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Custom Path's
local home_path = os.getenv("HOME")

local logger = require("utils.logger")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- beautiful.init(home_path .. "/.dotfiles/awesome/config/theme.lua")
-- beautiful.get().wallpaper = home_path .. "/.dotfiles/wallpapers/Deep_Purple.jpg"

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after = { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
            menu_awesome,
            { "Debian", debian.menu.Debian_menu.Debian },
            menu_terminal,
        }
    })
end


local awesome_icon_widget = wibox.widget {
    image  = home_path .. "/.dotfiles/awesome/config/awesomewm-icon.svg",
    resize = true, -- Resizes the image to fit the widget size
    widget = wibox.widget.imagebox,
}

local awesome_icon = wibox.widget {
    widget       = wibox.widget.textbox,
    font         = beautiful.font_family .. " " .. "15",
    markup       = "<span>\u{f354}</span>",
    forced_width = 20,
}

local awesome_icon_container_widget = wibox.widget {
    {
        awesome_icon,
        halign = 'center', -- Horizontal alignment
        valign = 'center', -- Vertical alignment
        widget = wibox.container.place,
    },
    right = 2,
    left = 5,
    widget  = wibox.container.margin,
}

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                      menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local divider_widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = "|",
}

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    local tag_names_with_spaces = {}
    for _, tag in ipairs(tag_names) do
        table.insert(tag_names_with_spaces, " " .. tag .. " ")
    end
    -- Each screen has its own tag table.
    local screen_tags = awful.tag(
        tag_names_with_spaces,
        s,
        awful.layout.layouts[0]
    )

    if screen_tags[4] then
        screen_tags[4]:view_only()
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 35 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            {
                {
                    -- Left Widgets
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 3,
                    -- mylauncher,
                    awesome_icon_container_widget,
                    tasklist_widget(s),
                    s.mypromptbox,
                },
                nil,
                {
                    -- Right Widgets
                    layout = wibox.layout.fixed.horizontal,
                    -- mykeyboardlayout,
                    -- wibox.widget.systray(),
                    --mytextclock,
                    brightness_widget.get_widget(),
                    volume_widget.get_widget(),
                    battery_widget,
                    wibox.widget {
                        divider_widget,
                        right = 10,
                        widget = wibox.container.margin
                    },
                    calendar_widget,
                    -- s.mylayoutbox,
                },
                layout = wibox.layout.align.horizontal,
            },
            {
                -- Middle Widget
                taglist_widget(s),
                layout = wibox.container.background,
            },
            layout = wibox.layout.stack,
        },
        layout = wibox.container.margin,
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    -- awful.key({ modkey, }, "j",
    --     function()
    --         awful.client.focus.byidx(1)
    --     end,
    --     { description = "focus next by index", group = "client" }
    -- ),
    -- awful.key({ modkey, }, "k",
    --     function()
    --         awful.client.focus.byidx(-1)
    --     end,
    --     { description = "focus previous by index", group = "client" }
    -- ),
    awful.key({ modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    -- awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    --     { description = "swap with next client by index", group = "client" }),
    -- awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    --     { description = "swap with previous client by index", group = "client" }),
    -- awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    --     { description = "focus the next screen", group = "screen" }),
    -- awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    --     { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "t", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, }, "e", function() awful.spawn("nautilus") end,
        { description = "open Nautilus", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    -- awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
    --     { description = "increase master width factor", group = "layout" }),
    -- awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
    --     { description = "decrease master width factor", group = "layout" }),
    -- awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    --     { description = "increase the number of master clients", group = "layout" }),
    -- awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    --     { description = "decrease the number of master clients", group = "layout" }),
    -- awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    --     { description = "increase the number of columns", group = "layout" }),
    -- awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    --     { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    awful.key({ modkey }, "p", function()
            awful.spawn.with_shell('rofi -show drun -theme "Arc-Dark"')
        end,
        { description = "show the menubar", group = "launcher" }),

    -- Custom
    awful.key({ modkey, "Control" }, "d", function()
            awful.spawn.with_shell(home_path .. "/.dotfiles/awesome/scripts/setup_extra_monitor.sh")
        end,
        { description = "Setup extra monitor", group = "launcher" }),
    -- Manage Volume
    awful.key({}, "XF86AudioRaiseVolume", function()
        volume_widget.increase()
    end, { description = "Increase volume", group = "media" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        volume_widget.decrease()
    end, { description = "Decrease volume", group = "media" }),

    awful.key({}, "XF86AudioMute", function()
        volume_widget.mute()
    end, { description = "Mute volume", group = "media" }),

    awful.key({}, "XF86MonBrightnessUp", function()
        brightness_widget.increase()
    end),
    awful.key({}, "XF86MonBrightnessDown", function()
        brightness_widget.decrease()
    end),
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn.with_shell("playerctl play-pause")
    end, { description = "Toggle Play - Pause", group = "media" }),
    awful.key({}, "XF86AudioNext", function()
        awful.spawn.with_shell("playerctl next")
    end, { description = "Play Next", group = "media" }),
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn.with_shell("playerctl previous")
    end, { description = "Play Previous", group = "media" }),

    awful.key({}, "Print", function()
        awful.spawn.with_shell("flameshot gui")
    end, { description = "Take a screenshot", group = "media" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" }),
        awful.key({ modkey }, "i", 
        function () 
            awful.screen.focus_relative(1) 
        end,
        {description = "focus the next screen", group = "screen"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i, key in ipairs(tag_names) do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, key,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag " .. key, group = "tag" }),

        -- Move client to tag.
        awful.key({ modkey, "Shift" }, key,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag " .. key, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Custom Scripts
awful.spawn.with_shell(home_path .. "/.dotfiles/awesome/scripts/setup_environment.sh")
