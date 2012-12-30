vicious = require("vicious")
require("wibox")
--require("blingbling")
--require("revelation")

-- Space
space       = widget({type = "textbox" })
space.width = 10

-- Spacer ][
spacer       = widget({ type = "imagebox" })
spacer.image = image(beautiful.widget_spacer)

-- Left side
lside       = widget({ type = "imagebox" })
lside.image = image(beautiful.widget_left)

-- Right side
rside       = widget({ type = "imagebox" })
rside.image = image(beautiful.widget_right)

-- Date and time
date_format     = "%a %d/%m/%Y, <b>%H:%M</b>"
date_icon       = widget({ type = "imagebox" })
date_icon.image = image(beautiful.widget_date)
date_widget     = widget({ type = "textbox" })
vicious.register(date_widget, vicious.widgets.date, date_format, 61)

-- Memory usage
mem_icon        = widget({ type = "imagebox" })
mem_icon.image  = image(beautiful.widget_mem)
mem_widget      = widget({ type = "textbox"})
vicious.register(mem_widget, vicious.widgets.mem, " $1%", 20)

-- CPU usage
cpu_icon        = widget({ type = "imagebox" })
cpu_icon.image  = image(beautiful.widget_cpu)
cpu_widget      = widget({ type = "textbox" })
vicious.register(cpu_widget, vicious.widgets.cpu, "$1%")

-- CPU temperature
temp_widget = widget({ type= "textbox" })
vicious.register(temp_widget, vicious.widgets.thermal,
function (widget, args)
    if args[1] >= 60 then
        return " @ <span color='#E84F4F'><b>" .. args[1] .. "°C</b></span>"
    else
        return " @ " .. args[1] .. "°C"
    end
end, 20, {"coretemp.0", "core"})

-- Battery
bat_icon        = widget({ type = "imagebox" })
bat_icon.image  = image(beautiful.widget_bat)
bat_widget      = widget({ type = "textbox" })

bat_toolt = awful.tooltip({ objects = { batwidtext,batwidget },})

vicious.register(bat_widget,vicious.widgets.bat,
    function(widget, args)
        if args[1] ~= "-" then
            btext = 'Pow '
        else
            btext = 'Bat '
        end

        if args[2] == -1 then
            return btext .. 'full'
        elseif args[2] < 10 then
            return btext .. '<span color="#da4939">' .. args[2] .. '</span>%'
        else
            return btext .. args[2] .. "%"
        end
    end, 30, "BAT0")

batmenu = awful.menu({items = {
    { "Auto", function() exec("sudo cpupower frequency-set -r -g ondemand", false) end },
    { "Ondemand", function() exec("sudo cpupower frequency-set -r -g ondemand", false) end },
    { "Powersave", function() exec("sudo cpupower frequency-set -r -g powersave", false) end },
    { "Performance", function() exec("sudo cpupower frequency-set -r -g performance", false) end }
}})

bat_widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function() batmenu:toggle() end)
))

-- Volume
vol_icon        = widget({ type = "imagebox" })
vol_icon.image  = image(beautiful.widget_vol)

vol_widget      = widget({ type = "textbox" })
vicious.register(vol_widget, vicious.widgets.volume,
    function(widget, args)
        if args[1] < 1 or args[2] == "♩" then
            vol_icon.image  = image(beautiful.widget_vol0)
            return "mute"
        else
            vol_icon.image  = image(beautiful.widget_vol)
            return args[1] .. "%"
        end
    end
, 2, "Master")

vol_icon:buttons(awful.util.table.join(
    awful.button({ }, 1, function() shell_exec("amixer -q set Master toggle") end),
    awful.button({ }, 4, function() shell_exec("amixer -c 0 set Master 1+ unmute") end),
    awful.button({ }, 5, function() shell_exec("amixer -c 0 set Master 1-") end)
))

-- MPD

-- Variável que faz login automaticamente no MPD
SENHA = "SuaSenhaAqui"
HOST = "localhost"
PORTA = "6600"
NCMPCPP= "ncmpcpp -h "..SENHA.."@localhost"

mpd_icon        = widget({ type = "imagebox" })
mpd_icon.image  = image(beautiful.widget_mpd)
mpd_widget      = widget({ type = "textbox" })
vicious.register(mpd_widget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
            return " - "
        elseif args["{state}"] == "Pause" then
            return "Paused"
        else 
            return args["{Artist}"]..' - '.. args["{Title}"]
        end
    end, 8, {SENHA, HOST, PORTA})

mpd_icon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () shell_exec("urxvt -e " .. NCMPCPP, false) end)
))

-- MPD controls
music_play = awful.widget.launcher({
    image = beautiful.widget_play,
    command = NCMPCPP .. " play"})

  music_pause = awful.widget.launcher({
    image = beautiful.widget_pause,
    command = NCMPCPP .. " pause"})

  music_stop = awful.widget.launcher({
    image = beautiful.widget_stop,
    command = NCMPCPP .. " stop"})

  music_prev = awful.widget.launcher({
    image = beautiful.widget_prev,
    command = NCMPCPP .. " prev"})

  music_next = awful.widget.launcher({
    image = beautiful.widget_next,
    command = NCMPCPP .. " next"})

-- Net Widget
intrf = "eth0"
netdown_icon = widget ({ type = "imagebox" })
netdown_icon.image = image(beautiful.widget_netdown)
netdown_icon.align = "middle"

netdown_widget = widget({ type = "textbox" })
vicious.register(netdown_widget, vicious.widgets.net,"${" .. intrf .. " down_kb}", 3)

netup_icon = widget ({ type = "imagebox" })
netup_icon.image = image(beautiful.widget_netup)
netup_icon.align = "middle"

netup_widget = widget({ type = "textbox" })
vicious.register(netup_widget, vicious.widgets.net, "${" .. intrf .. " up_kb}", 3)
