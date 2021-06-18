-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local freedesktop = require("freedesktop")
local battery_widget = require("battery-widget") -- https://github.com/deficient/battery-widget
local volume_control = require("volume-control") -- https://github.com/deficient/volume-control
local brightness     = require("brightness") -- https://github.com/deficient/brightness

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
tags = {
--    " いち ",
--    "  に  ",
--    " さん ",
--    " よん ",
--    "  ご  ",
--    " 1 ",
--    " 2 ",
--    " 3 ",
--    " 4 ",
--    " 5 ",
    " "..utf8.char(0x2022).." ",
    " "..utf8.char(0x2022).." ",
    " "..utf8.char(0x2022).." ",
    " "..utf8.char(0x2022).." ",
    " "..utf8.char(0x2022).." ",
}

-- Themes define colours, icons, font and wallpapers.
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")

-- This is used later as the default terminal and editor to run.
terminal = os.execute("command -v alacritty") and "alacritty" or "urxvt"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

lock_cmd = "light-locker-command -l"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.floating,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "lock", lock_cmd },
    { "quit", function() awesome.quit() end}
}

local mymainmenu = freedesktop.menu.build({
        icon_size = 16,
        before = {
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "chromium", "chromium" },
            { "terminal", terminal },
        },
        after = {
            { "reboot", "systemctl reboot" },
            { "shutdown", "systemctl poweroff" }
        },
    })

local mylauncher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = mymainmenu,
    })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--menubar.menu_gen.generate(function (entries)
--    for i, e in pairs(entries) do
--        naughty.notify {
--            text = "hello "..e.name..", "..e.cmdline..", "..(e.icon or "-"),
--        }
--    end
--end)
-- }}}

-- Keyboard map indicator and switcher
--mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
local myspacer = wibox.widget.textbox("\u{e621}")

-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %m/%d %H:%M  ")
local month_calendar = awful.widget.calendar_popup.month({
        font = beautiful.font_xlarge,
        start_sunday = true,
    })
month_calendar:attach( mytextclock, "tr" )

volumecfg = volume_control({
        widget_text = {
            on = ' 音量: %3d%% ',
            off = ' 消音 ',
        }
    })

brightness_ctrl = brightness({})

local mybattery = battery_widget {
    ac_prefix = "充電: ",
    battery_prefix = "電池: ",
    limits = {
        { 25, beautiful.battery_danger },
        { 50, beautiful.battery_warning },
        {100, beautiful.battery_fine },
    },
    widget_text = " ${AC_BAT}${color_on}${percent}%${color_off} ",
    widget_font = beautiful.font,
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
    )

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpapers(s)
    gears.wallpaper.set(beautiful.bg_normal)

    -- signal
    for i = 1,#s.tags do
        s.tags[i]:connect_signal("property::selected", function (tag)
            gears.wallpaper.set(beautiful.bg_normal) -- clear all pixels
            if tag.selected and beautiful.wallpapers then
                gears.wallpaper.centered(beautiful.wallpapers[i], s, beautiful.bg_normal, 1.0)
            else
                gears.wallpaper.centered(beautiful.wallpaper, s, beautiful.bg_normal, 1.0)
            end
        end)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpapers)

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag(tags, s, awful.layout.layouts[1])

    -- Wallpaper
    set_wallpapers(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    --s.mylayoutbox = awful.widget.layoutbox(s)
    --s.mylayoutbox:buttons(gears.table.join(
    --                       awful.button({ }, 1, function () awful.layout.inc( 1) end),
    --                       awful.button({ }, 3, function () awful.layout.inc(-1) end),
    --                       awful.button({ }, 4, function () awful.layout.inc( 1) end),
    --                       awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    --s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    -- Create the wibar
    local wibar_ratio_width = 0.86
    s.mywibar = awful.wibar {
        position = "top",
        screen = s,
        strech = false,
        width = s.geometry.width * wibar_ratio_width,
    }

    -- Create a systray
    mysystray = wibox.widget.systray()

    -- Add widgets to the wibox
    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        { -- Middle widget
            layout = wibox.layout.flex.horizontal,
            s.mytasklist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            --mykeyboardlayout,
            mysystray,
            myspacer,
            volumecfg.widget,
            myspacer,
            mybattery,
            myspacer,
            mytextclock,
            --s.mylayoutbox,
        },
    }

    -- Create quicklaunch wibox
    local ql = {
        margin = 5,
        opacity = 0.05,
    }
    local quicklaunch_items = { layout = wibox.layout.flex.vertical }
    for i, v in pairs({
        { command = "chromium", image = "/usr/share/icons/hicolor/64x64/apps/chromium.png" },
        { command = "thunar",   image = "/usr/share/icons/hicolor/64x64/apps/Thunar.png" },
        { command = "typora",   image = "/usr/share/icons/hicolor/64x64/apps/typora.png" },
        { command = "steam",   image = "/usr/share/icons/hicolor/256x256/apps/steam.png" },
    }) do
        table.insert(quicklaunch_items, {
            { widget = awful.widget.launcher { command = v.command, image = v.image }},
            left = ql.margin, right = ql.margin, top = ql.margin, bottom = ql.margin,
            widget = wibox.container.margin,
        })
    end
    local quicklaunchbox = wibox {
        screen = s,
        type = s.mywibar.type,
        shape = function(cr, w, h) gears.shape.partially_rounded_rect(cr,w,h,false,true,true,false,120) end, -- tl,tr,br,bl
        --bg = beautiful.taglist_bg_focus,
        bg = beautiful.taglist_bg_occupied,
        width = s.mywibar.height,
        height = s.mywibar.height * #quicklaunch_items,
        ontop = true,
        opacity = ql.opacity,
        visible = true,
    }
    quicklaunchbox:setup { quicklaunch_items, layout = wibox.layout.flex.vertical }
    quicklaunchbox:geometry { awful.placement.top_left(mylaunchbox) }
    ql.width = quicklaunchbox.width
    ql.height = quicklaunchbox.height
    quicklaunchbox:connect_signal("mouse::enter", function (d)
        d.opacity = 1
        d.width = ql.width * 2
        d.height = ql.height * 2
    end)
    quicklaunchbox:connect_signal("mouse::leave", function (d)
        d.opacity = ql.opacity
        d.width = ql.width
        d.height = ql.height
    end)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end)
        --awful.button({ }, 4, awful.tag.viewnext),
        --awful.button({ }, 5, awful.tag.viewprev)
    ))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
        ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
        ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn("alacritty") end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "c", function () awful.spawn("chromium") end,
        {description = "open a chromium", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"}),

    -- Media
    awful.key({}, "XF86AudioRaiseVolume", function() volumecfg:up() end),
    awful.key({}, "XF86AudioLowerVolume", function() volumecfg:down() end),
    awful.key({}, "XF86AudioMute",        function() volumecfg:toggle() end),

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp",   function() brightness_ctrl:up() end),
    awful.key({}, "XF86MonBrightnessDown", function() brightness_ctrl:down() end)
    )

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),

    awful.key({ modkey, "Shift"   }, "Left",
        function (c)
            c.maximized = false
            c.width  = c.screen.workarea.width / 2
            c.height = c.screen.workarea.height
            c.x = c.screen.workarea.x
            c.y = c.screen.workarea.y
        end,
        {description = "snap left", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Right",
        function (c)
            c.maximized = false
            c.width  = c.screen.workarea.width / 2
            c.height = c.screen.workarea.height
            c.x = (c.screen.workarea.width - c.width)
            c.y = c.screen.workarea.y
        end,
        {description = "snap right", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Up",
        function (c)
            c.maximized = false
            c.width = c.screen.workarea.width
            c.height = c.screen.workarea.height / 2
            c.x = c.screen.workarea.x
            c.y = c.screen.workarea.y
        end,
        {description = "snap top", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Down",
        function (c)
            c.maximized = false
            c.width = c.screen.workarea.width
            c.height = c.screen.workarea.height / 2
            c.x = c.screen.workarea.x
            c.y = (c.screen.workarea.height - c.height)
        end,
        {description = "snap bottom", group = "client"})
    )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
        )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
local tile_classes = {
    "Alacritty",
    "Chromium",
    "code",
    "Code",
}

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        }
    },
    {
        rule_any = {
            class = tile_classes
        },
        properties = {
            floating = false,
            titlebars_enabled = false,
            maximized = false,
        }
    },
    {
        rule_any = {
            type = {
                "normal",
                "dialog",
            },
        },
        except_any = {
            class = tile_classes
        },
        properties = {
            floating = true,
            titlebars_enabled = true,
        },
        callback = function (c)
            if not c.maximized then
                c.width = math.min(c.screen.workarea.width * 0.6, c.width)
                c.height = math.min(c.screen.workarea.height * 0.8, c.height)
                c.x = (c.screen.workarea.width / 2) - (c.width / 2)
                c.y = (c.screen.workarea.height / 2) - (c.height / 2)
            end
        end
    },
    {
        rule_any = {
            class = {
                "Steam",
            },
        },
        properties = {
            titlebars_enabled = false,
        },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        )

    local height_old = c.height

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            --awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

    c.y = c.y - (height_old - c.height)
    c.height = height_old
end)

-- round corners
client.connect_signal("manage", function (c)
    c.shape = beautiful.client_shape
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
-- Update wallpaper files
awful.spawn.easy_async_with_shell("python ~/.config/awesome/reddit_kabegami.py "..#tags.." shiba,earthporn,cityporn", function (stdout, stderr, reason, exit_code)
    if #stdout > 0 then
        naughty.notify { title = "wallpaper", text = stdout }
    end
    if #stderr > 0 then
        naughty.notify { title = "wallpaper (error)", text = stderr }
    end

    for s in screen do
        s.selected_tag:emit_signal("property::selected")
    end
end)
awful.spawn.with_shell("~/.config/awesome/autorun.sh")
-- }}}
