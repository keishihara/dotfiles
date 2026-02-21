local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 14
config.use_ime = true -- IMEで日本語入力
config.window_background_opacity = 0.80
config.macos_window_background_blur = 5

-- config.color_scheme = "Catppuccin Macchiato"
config.color_scheme = "Chalk (base16)"
config.enable_tab_bar = true
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
-- タブバーを透明にする
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}
-- タブバーを背景と同じ色にする
local function get_scheme_background(cfg)
  local name = cfg.color_scheme
  if not name or name == "" then
    return nil
  end

  -- user-defined schemes (cfg.color_schemes)
  if cfg.color_schemes and cfg.color_schemes[name] and cfg.color_schemes[name].background then
    return cfg.color_schemes[name].background
  end

  -- built-in schemes
  local builtins = wezterm.color.get_builtin_schemes()
  if builtins[name] and builtins[name].background then
    return builtins[name].background
  end

  return nil
end
config.window_background_gradient = {
  colors = { get_scheme_background(config) or "#000000" },
}
config.show_new_tab_button_in_tab_bar = false

config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.show_close_tab_button_in_tabs = false

return config
