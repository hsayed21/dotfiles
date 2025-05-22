-- Quick reference for hotkeys
-- Terminal Management
-- ["CTRL+SHIFT+ALT+Q"] = "Close entire terminal",
-- ["CTRL+SHIFT+n"] = "New window",

-- Pane Management
-- ["CTRL+SHIFT+ALT+h"] = "Split pane right",
-- ["CTRL+SHIFT+ALT+v"] = "Split pane down",
-- ["CTRL+SHIFT+ALT+W"] = "Close current pane",
-- ["CTRL+9"] = "Pane select",
-- ["CTRL+ALT+z"] = "Toggle pane zoom state (maximize/restore pane)",
-- ["CTRL+ALT+LeftArrow"] = "Navigate to left pane",
-- ["CTRL+ALT+RightArrow"] = "Navigate to right pane",
-- ["CTRL+ALT+UpArrow"] = "Navigate to upper pane",
-- ["CTRL+ALT+DownArrow"] = "Navigate to lower pane",

-- Pane Resizing
-- ["CTRL+SHIFT+U"] = "Adjust pane size left",
-- ["CTRL+SHIFT+I"] = "Adjust pane size down",
-- ["CTRL+SHIFT+O"] = "Adjust pane size up",
-- ["CTRL+SHIFT+P"] = "Adjust pane size right",

-- Tab Management
-- ["CTRL+SHIFT+t"] = "New tab",
-- ["CTRL+SHIFT+w"] = "Close current tab",
-- ["CTRL+SHIFT+LEFT"] = "Previous tab",
-- ["CTRL+SHIFT+RIGHT"] = "Next tab",
-- ["CTRL+SHIFT+r"] = "Rename tab",

-- Visual Adjustments
-- ["CTRL+SHIFT+ALT+F"] = "Toggle fullscreen",
-- ["CTRL+SHIFT+ALT+E"] = "Toggle color scheme",
-- ["CTRL+SHIFT+ALT+d"] = "Toggle light/dark theme",
-- ["CTRL+SHIFT+ALT+O"] = "Toggle opacity",
-- ["CTRL+SHIFT+z"] = "Toggle font size (for presentations)",
-- ["CTRL+0"] = "Reset font size",
-- ["CTRL+="] = "Increase font size",
-- ["CTRL+-"] = "Decrease font size",

-- Clipboard and Selection
-- ["CTRL+SHIFT+c"] = "Copy selected text",
-- ["CTRL+SHIFT+v"] = "Paste text",
-- ["ALT+SHIFT+s"] = "Quick-select mode (mouse-free text selection)",

-- Utilities
-- ["CTRL+L"] = "Show debug overlay",
-- ["CTRL+f"] = "Search in terminal",
-- ["CTRL+SHIFT+p"] = "Open command palette (like VS Code)",
-- ["CTRL+ALT+SHIFT+t"] = "Launch Windows Terminal (fallback)",


-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Enable GPU acceleration
config.front_end = "OpenGL"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 144
config.prefer_egl = true


-- Performance optimizations
config.animation_fps = 1
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Linear"
config.enable_kitty_graphics = true
config.enable_scroll_bar = false
config.use_ime = true
config.scrollback_lines = 10000

-- Terminal compatibility
config.term = "xterm-256color"
config.enable_csi_u_key_encoding = true
config.alternate_buffer_wheel_scroll_speed = 3

config.default_cursor_style = "BlinkingBlock"
config.cell_width = 0.9
config.window_background_opacity = 0.9
config.font_size = 18.0
config.font_size = 14.0

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.inactive_pane_hsb = {
	saturation = 0.0,
	brightness = 1.0,
}

-- This is where you actually apply your config choices
--

-- color scheme toggling
wezterm.on("toggle-colorscheme", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Zenburn" then
		overrides.color_scheme = "Cloud (terminal.sexy)"
	else
		overrides.color_scheme = "Zenburn"
	end
	window:set_config_overrides(overrides)
end)

-- keymaps
config.keys = {
	{
		key = "E",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.EmitEvent("toggle-colorscheme"),
	},
	{
		key = "F",
		mods = "CTRL|SHIFT|ALT",
		action = act.ToggleFullScreen,
	},
	{
		key = "W",
		mods = "CTRL|SHIFT|ALT",
		action = act.CloseCurrentPane { confirm = false },
	},
	{
		key = "Q",
		mods = "CTRL|SHIFT|ALT",
		action = act.QuitApplication,
	},
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "U",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "O",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
	{
		key = "O",
		mods = "CTRL|ALT",
		-- toggling opacity
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.window_background_opacity == 1.0 then
				overrides.window_background_opacity = 0.9
			else
				overrides.window_background_opacity = 1.0
			end
			window:set_config_overrides(overrides)
		end),
	},
}

-- Add standard tab and window navigation keys
local standard_keys = {
  -- Tab management
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("DefaultDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  {
    key = "r",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine {
      description = "Enter new tab name",
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }
  },

  -- Window management
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },

  -- Font size adjustment
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "z", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-font-size") },

  -- Search
  { key = "f", mods = "CTRL", action = act.Search { CaseSensitiveString = "" } },

  -- Clipboard
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- Pane navigation
  { key = "LeftArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },

  -- Quick-select mode (mouse-free text selection)
  { key = "s", mods = "SHIFT|ALT", action = act.QuickSelect },

  -- Zoom pane toggle (maximize/restore pane)
  { key = "z", mods = "CTRL|ALT", action = act.TogglePaneZoomState },
}

-- Add these standard keys to your existing configuration
for _, key_entry in ipairs(standard_keys) do
  table.insert(config.keys, key_entry)
end

-- For example, changing the color scheme:
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {
	-- background = '#3b224c',
	-- background = "#181616", -- vague.nvim bg
	-- background = "#080808", -- almost black
	background = "#0c0b0f", -- dark purple
	-- background = "#020202", -- dark purple
	-- background = "#17151c", -- brighter purple
	-- background = "#16141a",
	-- background = "#0e0e12", -- bright washed lavendar
	-- background = 'rgba(59, 34, 76, 100%)',
	cursor_border = "#bea3c7",
	-- cursor_fg = "#281733",
	cursor_bg = "#bea3c7",
	-- selection_fg = '#281733',

	tab_bar = {
		background = "#0c0b0f",
		-- background = "rgba(0, 0, 0, 0%)",
		active_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#bea3c7",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = "#0c0b0f",
			fg_color = "#f8f2f5",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},

		new_tab = {
			-- bg_color = "rgba(59, 34, 76, 50%)",
			bg_color = "#0c0b0f",
			fg_color = "white",
		},
	},
}

config.window_frame = {
	font = wezterm.font({ family = "FiraCode Nerd Font Mono", weight = "Regular" }),
	active_titlebar_bg = "#0c0b0f",
	-- active_titlebar_bg = "#181616",
}

-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.window_decorations = "NONE | RESIZE"
config.default_prog = { "pwsh.exe", "-NoLogo" }
config.initial_cols = 80
-- config.window_background_image = "C:/dev/misc/berk.png"
-- config.window_background_image_hsb = {
-- 	brightness = 0.1,
-- }

-- Font configuration
config.font = wezterm.font({
  family = "FiraCode Nerd Font Mono",
  weight = "Regular",
  harfbuzz_features = {"calt=1", "clig=1", "liga=1"}, -- Font ligatures
})

-- Font size adjustment
config.font_size = 14.0
config.line_height = 1.1  -- Slightly more readable line spacing

-- Add a key to toggle between font sizes (good for presentations)
wezterm.on("toggle-font-size", function(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.font_size then
    overrides.font_size = 20.0  -- Larger size for presentations
  else
    overrides.font_size = nil  -- Reset to default
  end
  window:set_config_overrides(overrides)
end)

-- Better tab bar customization
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true

-- Custom tab titles
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = tab.tab_index .. ": " .. pane.title
  return {
    { Text = " " .. title .. " " },
  }
end)

-- Window appearance
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

-- Window background image with adjustable opacity
-- Uncomment and adjust path to use
-- config.window_background_image = "g:/My Drive/dotfiles/assets/img/wallpaper.jpeg"
-- config.window_background_image_hsb = {
--   brightness = 0.1,
--   saturation = 0.5,
--   hue = 1.0,
-- }

-- Text reflowing on window resize
config.allow_win32_input_mode = true

-- Window close confirmation
config.window_close_confirmation = "AlwaysPrompt"

-- GPU settings for better performance
config.front_end = "OpenGL"  -- Usually best for Windows

-- Color scheme management - switching between dark and light theme
wezterm.on("toggle-theme", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.color_scheme or overrides.color_scheme == "Cloud (terminal.sexy)" then
    overrides.color_scheme = "Solarized (light) (terminal.sexy)"
    -- Use a light background image
    -- overrides.window_background_image = "g:/My Drive/dotfiles/assets/img/light_wallpaper.jpg"
  else
    overrides.color_scheme = "Cloud (terminal.sexy)"
    -- Use a dark background image
    -- overrides.window_background_image = "g:/My Drive/dotfiles/assets/img/wallpaper.jpeg"
  end
  window:set_config_overrides(overrides)
end)

-- Add light/dark theme toggle
table.insert(config.keys, {
  key = "d",
  mods = "CTRL|SHIFT|ALT",
  action = wezterm.action.EmitEvent("toggle-theme"),
})

-- Enable ligatures (connects certain character combinations)
config.harfbuzz_features = {"calt=1", "clig=1", "liga=1"}

-- Multikey support - allows for "dead keys" functionality
config.use_dead_keys = true

-- Auto-dim inactive panes (make active pane more visible)
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.8,
}

-- Set up status bar at bottom of window
config.status_update_interval = 1000
wezterm.on("update-status", function(window, pane)
  -- Get current date and time
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")

  -- Get current CPU and memory usage if needed
  -- local success, stdout, stderr = wezterm.run_child_process({"wmic", "cpu", "get", "loadpercentage"})
  -- local cpu = success and stdout:match("(%d+)") or "?"

  -- Set items to show in status bar
  window:set_right_status(wezterm.format({
    { Text = " " .. date .. " " },
  }))
end)

-- Add a key to launch Windows Terminal (in case wezterm has issues)
table.insert(config.keys, {
  key = "t",
  mods = "CTRL|ALT|SHIFT",
  action = wezterm.action_callback(function(window, pane)
    wezterm.run_child_process({"wt.exe"})
  end),
})

-- Command palette (like VS Code)
table.insert(config.keys, {
  key = "p",
  mods = "CTRL|SHIFT",
  action = act.ActivateCommandPalette,
})

-- Process notifications when terminal bells
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- Spawn a notification if a command takes longer than this threshold
wezterm.on("command-finished", function(window, pane, command, status)
  local duration = status.complete_timestamp - status.start_timestamp
  -- Only notify for commands taking more than 30 seconds
  if duration > 30 then
    local notification_command = string.format(
      'msg "%s" "Command finished: %s (%.2f seconds)"',
      window:get_title(),
      command,
      duration
    )
    -- This would use Windows PowerShell to display a toast notification
    wezterm.run_child_process({"powershell.exe", "-c", notification_command})
  end
end)

-- -- Domain configuration for different environments
-- config.unix_domains = {
--   {
--     name = "unix",
--   },
-- }

-- Default startup directory
-- config.default_cwd = "C:/Users/" .. os.getenv("USERNAME")

-- Set default domain
-- config.default_domain = "DefaultDomain"

-- Startup behavior
-- wezterm.on("gui-startup", function(cmd)
--   -- Default layout: one tab with powershell
--   local tab, pane, window = mux.spawn_window({
--     cwd = "C:/Users/" .. os.getenv("USERNAME"),
--   })

--   -- Set window position and size
--   window:gui_window():set_position(100, 100)
--   window:gui_window():set_inner_size(1200, 800)
-- end)

config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- -- Launch menu for common programs
-- config.launch_menu = {
--   {
--     label = "PowerShell",
--     args = {"powershell.exe", "-NoLogo"},
--   },
--   {
--     label = "Command Prompt",
--     args = {"cmd.exe"},
--   },
--   {
--     label = "Git Bash",
--     args = {"C:/Program Files/Git/bin/bash.exe", "-l"},
--   },
--   {
--     label = "Admin PowerShell",
--     args = {"powershell.exe", "-NoLogo", "-Command", "Start-Process powershell -Verb RunAs"},
--   },
-- }

-- and finally, return the configuration to wezterm
return config
