---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

-- https://github.com/tst2005/lua-sputnikcolors
local colors = require("lua-sputnikcolors.lua.colors")

local theme = {}

local function zfill(str, len)
    return string.sub(string.rep("0", len) .. str, -len)
end
local function mod_alpha(col, alpha)
    return string.sub(col, 0, 7) .. zfill(alpha, 2)
end

local alpha = "e0"

-- palette {{{
ColorValues = {}
ColorValues.__index = ColorValues
function ColorValues:new(spcolor, size)
    local x = {}
    setmetatable(x, ColorValues)
    x.size = size or 3
    x.color = spcolor:to_rgb()
    x.spcolor = colors.new(x.color)

    x.tints = spcolor:tints(size)
    for i,t in ipairs(x.tints) do x.tints[i] = t:to_rgb() end

    x.shades = spcolor:shades(size)
    for i,t in ipairs(x.shades) do x.shades[i] = t:to_rgb() end

    return x
end

ColorPalette = {}
ColorPalette.__index = ColorPalette
function ColorPalette:new(rgba_code, size, desaturate)
    local x = {}
    setmetatable(x, ColorPalette)
    rgba_code = rgba_code:gsub("^%[[0-9]+%]", "")
    local c = colors.new(rgba_code:sub(0, 7)):desaturate_by(desaturate or 1)
    local n1, n2    = c:triadic()
    x.size          = size or 3
    x.primary       = ColorValues:new(c, size)
    x.complementary = ColorValues:new(c:complementary(), size)
    x.neighbor1     = ColorValues:new(n1, size)
    x.neighbor2     = ColorValues:new(n2, size)
    return x
end

local n = 9
theme.palette1 = ColorPalette:new(xrdb.color6, n, 0.5)
theme.palette2 = ColorPalette:new("#c8c8c8", n, 0.5)
theme.palette3 = ColorPalette:new(xrdb.background, n, 0.5)
-- }}}

local fontname = "RictyDiscord Nerd Font"
local fontsize = 8
theme.font = fontname.." "..fontsize 
theme.font_large = fontname.." "..(fontsize * 1.4)
theme.font_xlarge = fontname.." "..(fontsize * 1.8)
theme.tasklist_font = theme.font_large
theme.taglist_font = theme.font

theme.bg_normal     = mod_alpha(theme.palette3.primary.color, alpha)
theme.bg_focus      = mod_alpha(theme.palette1.primary.shades[4], alpha)
theme.bg_urgent     = xrdb.color9
theme.bg_minimize   = theme.palette3.primary.shades[4]
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = theme.palette2.primary.color
theme.fg_focus      = theme.fg_normal
theme.fg_urgent     = theme.bg_normal
theme.fg_minimize   = theme.palette2.primary.shades[6]

theme.useless_gap   = dpi(6)
theme.border_width  = dpi(1)
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.palette1.primary.shades[7]
theme.border_marked = theme.palette1.complementary.shades[5]

theme.battery_danger  = xrdb.color1
theme.battery_warning = xrdb.color3
theme.battery_fine    = xrdb.color2

theme.taglist_fg_empty    = theme.palette1.primary.shades[3]
theme.taglist_fg_occupied = theme.palette1.primary.tints[3]
theme.taglist_fg_focus    = theme.palette1.primary.tints[9]

theme.taglist_bg_empty    = theme.palette3.primary.color
theme.taglist_bg_occupied = theme.palette1.primary.shades[7]
theme.taglist_bg_focus    = theme.palette1.primary.shades[6]

theme.tasklist_fg_normal = theme.palette2.primary.color
theme.tasklist_bg_normal = theme.palette3.primary.color
theme.tasklist_fg_focus = theme.palette2.primary.shades[2]
theme.tasklist_bg_focus = theme.palette3.primary.shades[2]

theme.titlebar_bg_focus = theme.palette3.primary.tints[1]

theme.client_corner_radius = 12
theme.widget_corner_radius = 4

theme.client_shape = function(cr, w, h) gears.shape.rounded_rect(cr,w,h,theme.client_corner_radius) end
theme.bar_shape = function(cr, w, h) gears.shape.rounded_rect(cr,w,h,theme.widget_corner_radius) end

theme.taglist_shape = theme.rectangle
theme.tasklist_shape = theme.rectangle
theme.wibar_shape = theme.bar_shape

theme.tasklist_disable_icon = true
theme.tasklist_disable_task_name = false
theme.tasklist_align = "center"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
--local taglist_square_size = dpi(8)
--theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
--    taglist_square_size, theme.fg_normal
--)
--theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
--    taglist_square_size, theme.fg_normal
--)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(30)
theme.menu_width  = dpi(200)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

--theme.wallpaper = themes_path.."default/background.png"
local mywall = os.getenv("HOME").."/default_wallpaper"
local defaultwall = themes_path.."default/background.png"
theme.wallpaper = gfs.file_readable(mywall) and mywall or defaultwall

theme.wallpapers = {}
for i = 0,10 do
    local mywall = os.getenv("HOME").."/default_wallpaper"..i
    table.insert(theme.wallpapers, gfs.file_readable(mywall) and mywall or defaultwall)
end

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.bg_normal
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
