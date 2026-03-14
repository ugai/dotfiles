local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
	-- Preferred (install manually)
	"Berkeley Mono",
	-- Windows built-in / common
	"Cascadia Code",
	"Consolas",
	-- Linux common
	"JetBrains Mono",
	"DejaVu Sans Mono",
	-- Japanese: preferred → Windows → Linux
	"M PLUS 1 Code",
	"BIZ UDGothic",
	"Yu Gothic",
	"Meiryo",
	"Noto Sans CJK JP",
})
config.color_scheme = "flexoki-dark"

config.front_end = "WebGpu"

config.window_background_opacity = 0.75
config.win32_system_backdrop = "Acrylic"

config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 100,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 200,
	target = "BackgroundColor",
}

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

-- Window decorations: integrate title bar buttons into tab bar
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
	active_titlebar_bg = "none",
	inactive_titlebar_bg = "none",
	font = wezterm.font_with_fallback({
		"Berkeley Mono",
		"Cascadia Code",
		"Consolas",
		"M PLUS 1 Code",
		"BIZ UDGothic",
	}),
}

config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.colors = {
	scrollbar_thumb = "#333",
	visual_bell = "#444444",
}

-- Panes
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }

config.use_ime = true

config.initial_cols = 120
config.initial_rows = 30

config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

if wezterm.target_triple:find("windows") then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Leader key (CTRL+B, like tmux)
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Pane splitting
	{ key = "%", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Pane navigation (vim-style + arrow keys)
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "LeftArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "DownArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "UpArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "RightArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	-- Pane close
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	-- Tab management
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	-- Zoom pane
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
	-- Workspace switcher
	{ key = "s", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }) },
	-- Reset font size
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
}

-- Mouse bindings
config.mouse_bindings = {
	-- Right-click: copy+clear if text is selected, paste otherwise
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local sel = window:get_selection_text_for_pane(pane)
			if sel and sel ~= "" then
				window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
				window:perform_action(wezterm.action.ClearSelection, pane)
			else
				window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
			end
		end),
	},
	-- CTRL+scroll to zoom font size
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "CTRL",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "CTRL",
		action = wezterm.action.DecreaseFontSize,
	},
}

-- Window title: CWD basename if available (requires OSC 7 from shell),
-- fallback to the title set by the foreground process (OSC 0/2).
-- Linux: source wezterm shell integration in .zshrc / .bashrc.
-- Windows: add OSC 7 to PowerShell profile manually.
--   https://wezterm.org/shell-integration.html
wezterm.on("format-window-title", function(tab, pane, tabs, panes, _)
	local cwd = pane:get_current_working_dir()
	if cwd then
		local path = type(cwd) == "userdata" and cwd.file_path or tostring(cwd)
		local name = path:match("([^/\\]+)[/\\]?$")
		if name and name ~= "" then
			return name
		end
	end
	return tab.active_pane.title
end)

-- Status bar: workspace name (left) + time (right)
wezterm.on("update-status", function(window, _)
	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Text = "  " .. window:active_workspace() .. "  " },
	}))
	window:set_right_status(wezterm.format({
		{ Text = wezterm.strftime("  %H:%M  ") },
	}))
end)

-- Local overrides (not tracked by git): ~/.wezterm_local.lua
-- Example: config.color_scheme = "Tokyo Night"
local ok, local_config = pcall(require, "wezterm_local")
if ok then
	local_config.apply(config)
end

wezterm.on("gui-startup", function(cmd)
	local _tab, _pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
