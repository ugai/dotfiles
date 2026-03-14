local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
	"Berkeley Mono",
	"M PLUS 1 Code",
})
config.color_scheme = "flexoki-dark"

config.front_end = "WebGpu"

config.audible_bell = "Disabled"

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.use_ime = true

config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

config.default_prog = { "pwsh.exe", "-NoLogo" }

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
