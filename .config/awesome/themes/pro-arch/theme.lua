
                -- [    Pro Dark theme for Awesome 3.5.5    ] --
                -- [            author: Julio Batista Silva ] --
                -- [    http://github.com/gyrfalco/pro      ] --

-- // got the idea from Holo theme by Luke Bonham (https://github.com/copycat-killer)

-- patch for taglist: https://github.com/awesomeWM/awesome/pull/39

theme               = {}
config_dir          = awful.util.getdir("config")
theme.dir           = config_dir .. "/themes/pro-arch"
theme.icons         = theme.dir .. "/icons"
theme.widgets_dir   = theme.icons .. "/panel/widgets"
theme.layouts_dir   = theme.icons .. "/panel/layouts"

theme.wallpaper     = theme.dir .. "/wallpapers/wallpaper.jpg"
theme.panel         = "png:" .. theme.icons .. "/panel/panel.png"
theme.font          = "Terminus 9"

theme.fg_normal     = "#888888"
theme.fg_focus      = "#e4e4e4"
theme.fg_urgent     = "#CC9393"

theme.bg_normal     = "#3F3F3F"
theme.bg_focus      = "#5a5a5a"
theme.bg_urgent     = "#3F3F3F"
theme.bg_systray    = "#343434"

theme.clockgf       = "#d5d5c3"

theme.arch_icon     = theme.icons .. "/arch_blue.png"

-- | Borders | --

theme.border_width  = 4
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#6F6F6F"
theme.border_marked = "#CC9393"

-- | Menu | --

theme.menu_height = 16
theme.menu_width  = 160

-- | Layout | --

theme.layout_floating   = theme.layouts_dir .. "/floating.png"
theme.layout_tile       = theme.layouts_dir .. "/tile.png"
theme.layout_tileleft   = theme.layouts_dir .. "/tileleft.png"
theme.layout_tilebottom = theme.layouts_dir .. "/tilebottom.png"
theme.layout_tiletop    = theme.layouts_dir .. "/tiletop.png"

-- | Taglist | --

theme.taglist_bg_empty    = "png:" .. theme.icons .. "/panel/taglist/empty.png"
theme.taglist_bg_occupied = "png:" .. theme.icons .. "/panel/taglist/occupied.png"
theme.taglist_bg_urgent   = "png:" .. theme.icons .. "/panel/taglist/urgent.png"
theme.taglist_bg_focus    = "png:" .. theme.icons .. "/panel/taglist/focus.png"
theme.taglist_font        = "Terminus 11"

-- | Tasklist | --

theme.tasklist_font                 = "Terminus 8"
theme.tasklist_disable_icon         = true
theme.tasklist_bg_normal            = "png:" .. theme.icons .. "/panel/tasklist/normal.png"
theme.tasklist_bg_focus             = "png:" .. theme.icons .. "/panel/tasklist/focus.png"
theme.tasklist_bg_urgent            = "png:" .. theme.icons .. "/panel/tasklist/urgent.png"
theme.tasklist_fg_focus             = "#DDDDDD"
theme.tasklist_fg_urgent            = "#EEEEEE"
theme.tasklist_fg_normal            = "#AAAAAA"
theme.tasklist_floating             = ""
theme.tasklist_sticky               = ""
theme.tasklist_ontop                = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

-- | Widget | --

theme.widget_display   = theme.widgets_dir .. "/display/widget_display.png"
theme.widget_display_r = theme.widgets_dir .. "/display/widget_display_r.png"
theme.widget_display_c = theme.widgets_dir .. "/display/widget_display_c.png"
theme.widget_display_l = theme.widgets_dir .. "/display/widget_display_l.png"

-- | MPD | --

theme.mpd_prev  = theme.widgets_dir .. "/mpd/mpd_prev.png"
theme.mpd_nex   = theme.widgets_dir .. "/mpd/mpd_next.png"
theme.mpd_stop  = theme.widgets_dir .. "/mpd/mpd_stop.png"
theme.mpd_pause = theme.widgets_dir .. "/mpd/mpd_pause.png"
theme.mpd_play  = theme.widgets_dir .. "/mpd/mpd_play.png"
theme.mpd_sepr  = theme.widgets_dir .. "/mpd/mpd_sepr.png"
theme.mpd_sepl  = theme.widgets_dir .. "/mpd/mpd_sepl.png"

-- | Separators | --

theme.spr    = theme.icons .. "/panel/separators/spr.png"
theme.sprtr  = theme.icons .. "/panel/separators/sprtr.png"
theme.spr4px = theme.icons .. "/panel/separators/spr4px.png"
theme.spr5px = theme.icons .. "/panel/separators/spr5px.png"

-- | Clock / Calendar | --

theme.widget_clock = theme.widgets_dir .. "/widget_clock.png"
theme.widget_cal   = theme.widgets_dir .. "/widget_cal.png"

-- | CPU / TMP | --

theme.widget_cpu    = theme.widgets_dir .. "/widget_cpu.png"
-- theme.widget_tmp = theme.widgets_dir .. "/widget_tmp.png"

-- | MEM | --

theme.widget_mem = theme.widgets_dir .. "/widget_mem.png"

-- | FS | --

theme.widget_fs     = theme.widgets_dir .. "/widget_fs.png"
theme.widget_fs_hdd = theme.widgets_dir .. "/widget_fs_hdd.png"

-- | Mail | --

theme.widget_mail = theme.widgets_dir .. "/widget_mail.png"

-- | NET | --

theme.widget_netdl = theme.widgets_dir .. "/widget_netdl.png"
theme.widget_netul = theme.widgets_dir .. "/widget_netul.png"

-- | Misc | --

theme.menu_submenu_icon = theme.icons .. "/submenu.png"

return theme

