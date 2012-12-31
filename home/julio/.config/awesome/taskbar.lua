require("widgets")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
top_wibox = {}
bot_wibox = {}
mypromptbox = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1,
        function (c)
            if c == client.focus then
              c.minimized = true
            else
              if not c:isvisible() then
                  awful.tag.viewonly(c:tags()[1])
              end
              -- This will also un-minimize
              -- the client, if needed
              client.focus = c
              c:raise()
            end
        end),

    awful.button({ }, 3,
        function ()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({ width=250 })
            end
        end),

    awful.button({ }, 4,
        function ()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.button({ }, 5,
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end)
)


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- Create an imagebox widget which will contains an icon indicating which
    -- layout we're using. We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
        function(c)
            return awful.widget.tasklist.label.currenttags(c, s) end,
        mytasklist.buttons)

    -- Top wibox
    top_wibox[s] = awful.wibox({
        position = "top",
        screen = s,
        height = beautiful.bar_height
    })

    top_wibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],

        rside,
        date_widget,
        date_icon,

        -- comente se nao tiver bateria
        --spacer,
        --bat_widget,
        --bat_icon,
        --lside,

        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- Bottom wibox
    bot_wibox[s] = awful.wibox({
        position = "bottom",
        screen   = s,
        height   = beautiful.bar_height
    })
    bot_wibox[s].widgets = {
        {
            music_prev,
            music_stop,
            music_pause,
            music_play,
            music_next,
            space,

            vol_icon,
            vol_widget,

            space,
            mpd_icon,
            mpd_widget,

            layout = awful.widget.layout.horizontal.leftright
        },
        rside,
        mem_widget,
        mem_icon,

        spacer,

        temp_widget,
        cpu_widget,
        cpu_icon,
        spacer,

        netup_widget,
        netup_icon,
        netdown_widget,
        netdown_icon,
        lside,

        layout = awful.widget.layout.horizontal.rightleft
    }
end
