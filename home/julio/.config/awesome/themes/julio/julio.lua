----------------------------------------
--          Theme by Julio
--  based on Zenburn by Adrian (anrxc)
----------------------------------------

require("awful.util")

theme = {}
config_dir                  = awful.util.getdir("config")
theme_dir                   = config_dir .. "/themes/julio"
icons_dir                   = theme_dir .. "/icons"
widgets_dir                 = icons_dir .. "/widgets/blue"
layouts_dir                 = theme_dir .. "/layouts"

wall_dir                    = "/home/julio/Imagens/Wallpapers/varios/Linux/Arch/"
wallpaper                   = wall_dir .. "1920x1080/newarchback.jpg"
theme.wallpaper_cmd         = { "awsetbg " .. wallpaper }

theme.font                  = "sans 8"

theme.fg_normal             = "#DCDCCC"
theme.fg_focus              = "#F0DFAF"
theme.fg_urgent             = "#CC9393"
theme.bg_normal             = "#3F3F3F"
theme.bg_focus              = "#1E2320"
theme.bg_urgent             = "#3F3F3F"


theme.border_width          = "4"
theme.border_normal         = "#3F3F3F"
theme.border_focus          = "#6F6F6F"
theme.border_marked         = "#CC9393"

theme.titlebar_bg_focus     = "#3F3F3F"
theme.titlebar_bg_normal    = "#3F3F3F"


theme.mouse_finder_color = "#CC9393"

theme.menu_height = "15"
theme.menu_width  = "100"

theme.bar_height = "18"


theme.taglist_squares_sel   = theme_dir .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = theme_dir .. "/taglist/squarez.png"

theme.arch_icon           = icons_dir .. "/arch_blue.png"
theme.menu_submenu_icon      = icons_dir .. "/submenu.png"
theme.tasklist_floating_icon = icons_dir .. "/tasklist/floatingw.png"

theme.layout_tile       = layouts_dir .. "/tile.png"
theme.layout_tileleft   = layouts_dir .. "/tileleft.png"
theme.layout_tilebottom = layouts_dir .. "/tilebottom.png"
theme.layout_tiletop    = layouts_dir .. "/tiletop.png"
theme.layout_fairv      = layouts_dir .. "/fairv.png"
theme.layout_fairh      = layouts_dir .. "/fairh.png"
theme.layout_spiral     = layouts_dir .. "/spiral.png"
theme.layout_dwindle    = layouts_dir .. "/dwindle.png"
theme.layout_max        = layouts_dir .. "/max.png"
theme.layout_fullscreen = layouts_dir .. "/fullscreen.png"
theme.layout_magnifier  = layouts_dir .. "/magnifier.png"
theme.layout_floating   = layouts_dir .. "/floating.png"


-- Widgets
theme.widget_date   = widgets_dir .. "/clock.png"
theme.widget_mem    = widgets_dir .. "/mem.png"
theme.widget_cpu    = widgets_dir .. "/cpu.png"
theme.widget_bat    = widgets_dir .. "/bat.png"
theme.widget_mail   = widgets_dir .. "/mail.png"
theme.widget_spacer = widgets_dir .. "/spacer.png"
theme.widget_left   = widgets_dir .. "/left.png"
theme.widget_right  = widgets_dir .. "/right.png"
theme.widget_mpd    = widgets_dir .. "/note.png"
theme.widget_play   = widgets_dir .. "/play.png"
theme.widget_pause  = widgets_dir .. "/pause.png"
theme.widget_stop   = widgets_dir .. "/stop.png"
theme.widget_prev   = widgets_dir .. "/prev.png"
theme.widget_next   = widgets_dir .. "/next.png"
theme.widget_vol    = widgets_dir .. "/spkr.png"
theme.widget_vol0   = widgets_dir .. "/spkr_mute.png"
theme.widget_netup  = widgets_dir .. "/net_up.png"
theme.widget_netdown = widgets_dir .. "/net_down.png"


theme.titlebar_close_button_focus  = theme_dir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme_dir .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme_dir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme_dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme_dir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme_dir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme_dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme_dir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme_dir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme_dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme_dir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme_dir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme_dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme_dir .. "/titlebar/maximized_normal_inactive.png"

return theme
