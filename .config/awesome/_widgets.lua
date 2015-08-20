-- Inspirado em https://github.com/gyrfalco/pro

-- | Markup | --

markup = lain.util.markup

space3 = markup.font("Terminus 3", " ")
space2 = markup.font("Terminus 2", " ")
vspace1 = '<span font="Terminus 3"> </span>'
vspace2 = '<span font="Terminus 3">  </span>'
clockgf = beautiful.clockgf

-- | Widgets | --

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- | MPD | --

prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.mpd_prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.mpd_nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.mpd_stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.mpd_pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.mpd_play)
mpd_sepl = wibox.widget.imagebox()
mpd_sepl:set_image(beautiful.mpd_sepl)
mpd_sepr = wibox.widget.imagebox()
mpd_sepr:set_image(beautiful.mpd_sepr)

mpdwidget = lain.widgets.mpd({
    settings = function ()
        if mpd_now.state == "play" then
            mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
            mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
            widget:set_markup(markup.font("Tamsyn 3", " ")
                              .. markup.font("Tamsyn 7",
                              mpd_now.artist
                              .. " - " ..
                              mpd_now.title
                              .. markup.font("Tamsyn 2", " ")))
            play_pause_icon:set_image(beautiful.mpd_pause)
            mpd_sepl:set_image(beautiful.mpd_sepl)
            mpd_sepr:set_image(beautiful.mpd_sepr)
        elseif mpd_now.state == "pause" then
            widget:set_markup(markup.font("Tamsyn 4", "") ..
                              markup.font("Tamsyn 7", "MPD PAUSED") ..
                              markup.font("Tamsyn 10", ""))
            play_pause_icon:set_image(beautiful.mpd_play)
            mpd_sepl:set_image(beautiful.mpd_sepl)
            mpd_sepr:set_image(beautiful.mpd_sepr)
        else
            widget:set_markup("")
            play_pause_icon:set_image(beautiful.mpd_play)
            mpd_sepl:set_image(nil)
            mpd_sepr:set_image(nil)
        end
    end
})

musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_display)
musicwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(ncmpcpp) end)))
prev_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc prev || ncmpcpp prev")
    mpdwidget.update()
end)))
next_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc next || ncmpcpp next")
    mpdwidget.update()
end)))
stop_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop || ncmpcpp stop")
    mpdwidget.update()
end)))
play_pause_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle")
    mpdwidget.update()
end)))

-- | Mail | --

--mail_widget = wibox.widget.textbox()
--vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)

--widget_mail = wibox.widget.imagebox()
--widget_mail:set_image(beautiful.widget_mail)
--mailwidget = wibox.widget.background()
--mailwidget:set_widget(mail_widget)
--mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(space3 .. cpu_now.usage .. "%" .. markup.font("Tamsyn 4", " "))
    end
})

widget_cpu = wibox.widget.imagebox()
widget_cpu:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_display)

-- tmp_widget = wibox.widget.textbox()
-- vicious.register(tmp_widget, vicious.widgets.thermal, vspace1 .. "$1°C" .. vspace1, 9, "thermal_zone0")

-- widget_tmp = wibox.widget.imagebox()
-- widget_tmp:set_image(beautiful.widget_tmp)
-- tmpwidget = wibox.widget.background()
-- tmpwidget:set_widget(tmp_widget)
-- tmpwidget:set_bgimage(beautiful.widget_display)

-- | MEM | --

mem_widget = lain.widgets.mem({
    settings = function()
        widget:set_markup(space3 .. mem_now.used .. "MB" .. markup.font("Tamsyn 4", " "))
    end
})

widget_mem = wibox.widget.imagebox()
widget_mem:set_image(beautiful.widget_mem)
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_display)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, vspace1 .. "${/ avail_gb}GB" .. vspace1, 2)

widget_fs = wibox.widget.imagebox()
widget_fs:set_image(beautiful.widget_fs)
fswidget = wibox.widget.background()
fswidget:set_widget(fs_widget)
fswidget:set_bgimage(beautiful.widget_display)

-- | NET | --

net_widgetdl = wibox.widget.textbox()
net_widgetul = lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", "  ") .. net_now.sent)
        net_widgetdl:set_markup(markup.font("Tamsyn 1", " ") .. net_now.received .. markup.font("Tamsyn 1", " "))
    end
})

widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = wibox.widget.background()
netwidgetdl:set_widget(net_widgetdl)
netwidgetdl:set_bgimage(beautiful.widget_display)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = wibox.widget.background()
netwidgetul:set_widget(net_widgetul)
netwidgetul:set_bgimage(beautiful.widget_display)

-- | Clock / Calendar | --

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)

local index = 1
local loop_widgets = { mytextclock, mytextcalendar }
local loop_widgets_icons = { beautiful.widget_clock, beautiful.widget_cal }

clockwidget:buttons(awful.util.table.join(awful.button({}, 1,
    function ()
        index = index % #loop_widgets + 1
        clockwidget:set_widget(loop_widgets[index])
        widget_clock:set_image(loop_widgets_icons[index])
    end)))
