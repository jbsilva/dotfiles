require("widgets")

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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() then
                    awful.tag.viewonly(c:tags()[1])
                end
                -- This will also un-minimize the client, if needed
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
            if client.focus then client.focus:raise() end
        end),
    awful.button({ }, 5,
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which
    -- layout we're using. We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- ===== Top wibox ===== --
    top_wibox[s] = awful.wibox({
        position = "top",
        screen = s,
        height = beautiful.bar_height
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(lside)
    right_layout:add(bat_icon)
    right_layout:add(bat_widget)
    right_layout:add(spacer)
    right_layout:add(date_icon)
    right_layout:add(date_widget)
    right_layout:add(rside)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    top_wibox[s]:set_widget(layout)


    -- ===== Bottom wibox ===== --
    bot_wibox[s] = awful.wibox({
        position = "bottom",
        screen   = s,
        height   = beautiful.bar_height
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(space)
    left_layout:add(lside)
    left_layout:add(music_prev)
    left_layout:add(music_stop)
    left_layout:add(music_pause)
    left_layout:add(music_play)
    left_layout:add(music_next)
    left_layout:add(spacer)
    left_layout:add(vol_icon)
    left_layout:add(vol_widget)
    left_layout:add(rside)

    -- Widgets that are aligned in the middle
    local middle_layout = wibox.layout.fixed.horizontal()
    middle_layout:add(mpd_icon)
    middle_layout:add(mpd_widget)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(lside)
    right_layout:add(netup_icon)
    right_layout:add(netup_widget)
    right_layout:add(netdown_icon)
    right_layout:add(netdown_widget)
    right_layout:add(spacer)
    right_layout:add(mem_icon)
    right_layout:add(mem_widget)
    right_layout:add(spacer)
    right_layout:add(cpu_icon)
    right_layout:add(cpu_widget)
    right_layout:add(temp_widget)
    right_layout:add(rside)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(middle_layout)
    layout:set_right(right_layout)

    bot_wibox[s]:set_widget(layout)
end
