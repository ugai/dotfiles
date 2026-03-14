local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

-- Fonts
local font_families = {
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
}
config.font = wezterm.font_with_fallback(font_families)

-- Appearance
config.color_scheme = "flexoki-dark"
config.colors = {
	scrollbar_thumb = "#333",
	visual_bell = "#444444",
}
config.front_end = "WebGpu"
config.window_background_opacity = 0.75
config.win32_system_backdrop = "Acrylic"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }

-- Bell
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 100,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 200,
	target = "BackgroundColor",
}

-- Tab bar & window decorations
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
	active_titlebar_bg = "none",
	inactive_titlebar_bg = "none",
	font = wezterm.font_with_fallback(font_families),
}

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- Window size & input
config.initial_cols = 120
config.initial_rows = 30
config.use_ime = true

-- Platform
if wezterm.target_triple:find("windows") then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Multi-pane split helpers
-- Usage: F9 → 2/3/4/g → h/v
local function pane_cwd(pane)
	local cwd = pane:get_current_working_dir()
	if cwd then
		return type(cwd) == "userdata" and cwd.file_path or tostring(cwd)
	end
end

-- Split into n equal panes along the given direction ("Right" or "Bottom")
local function split_line(pane, direction, n)
	local cwd = pane_cwd(pane)
	local current = pane
	for i = 0, n - 2 do
		current = current:split({ direction = direction, cwd = cwd, size = (n - 1 - i) / (n - i) })
	end
end

-- Split into 2x2 grid
local function split_grid(_, pane)
	local cwd = pane_cwd(pane)
	local right = pane:split({ direction = "Right", cwd = cwd, size = 0.5 })
	pane:split({ direction = "Bottom", cwd = cwd, size = 0.5 })
	right:split({ direction = "Bottom", cwd = cwd, size = 0.5 })
end

-- Close all panes in the current tab except the active one
local function close_other_panes(window, pane)
	local current_id = pane:pane_id()
	for _, p in ipairs(window:mux_window():active_tab():panes()) do
		if p:pane_id() ~= current_id then
			window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), p)
		end
	end
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
	{ key = "X", mods = "LEADER|SHIFT", action = wezterm.action_callback(close_other_panes) },
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
	-- Multi-pane split mode
	{ key = "F9", action = wezterm.action.ActivateKeyTable({ name = "split_mode", one_shot = false, timeout_milliseconds = 5000 }) },
}

-- Key tables for split mode: F9 → 2/3/4/g → h/v
config.key_tables = {
	split_mode = {
		{ key = "2", action = wezterm.action.ActivateKeyTable({ name = "split_dir_2", one_shot = true }) },
		{ key = "3", action = wezterm.action.ActivateKeyTable({ name = "split_dir_3", one_shot = true }) },
		{ key = "4", action = wezterm.action.ActivateKeyTable({ name = "split_dir_4", one_shot = true }) },
		{ key = "g", action = wezterm.action_callback(split_grid) },
		{ key = "Escape", action = wezterm.action.PopKeyTable },
	},
	split_dir_2 = {
		{ key = "h", action = wezterm.action_callback(function(_, p) split_line(p, "Right", 2) end) },
		{ key = "v", action = wezterm.action_callback(function(_, p) split_line(p, "Bottom", 2) end) },
		{ key = "Escape", action = wezterm.action.PopKeyTable },
	},
	split_dir_3 = {
		{ key = "h", action = wezterm.action_callback(function(_, p) split_line(p, "Right", 3) end) },
		{ key = "v", action = wezterm.action_callback(function(_, p) split_line(p, "Bottom", 3) end) },
		{ key = "Escape", action = wezterm.action.PopKeyTable },
	},
	split_dir_4 = {
		{ key = "h", action = wezterm.action_callback(function(_, p) split_line(p, "Right", 4) end) },
		{ key = "v", action = wezterm.action_callback(function(_, p) split_line(p, "Bottom", 4) end) },
		{ key = "Escape", action = wezterm.action.PopKeyTable },
	},
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

-- Status bar: workspace name + key table mode (left) + hints + time (right)
local split_mode_hints = {
	split_mode  = "SPLIT  2/3/4/g",
	split_dir_2 = "SPLIT-2  h/v",
	split_dir_3 = "SPLIT-3  h/v",
	split_dir_4 = "SPLIT-4  h/v",
}
wezterm.on("update-status", function(window, _)
	local mode = split_mode_hints[window:active_key_table() or ""]
	local left = "  " .. window:active_workspace() .. "  "
	if mode then
		left = left .. "  " .. mode .. "  "
	end
	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Text = left },
	}))
	window:set_right_status(wezterm.format({
		{ Text = "  F9:split  │  " .. wezterm.strftime("%H:%M  ") },
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
