-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "Manual", terminal .. " -e man awesome", beautiful.arch_icon },
   { "Restart", awesome.restart, beautiful.arch_icon },
   { "Quit", awesome.quit, beautiful.arch_icon }
}

office_menu = {
    {"Gvim", "gvim", beautiful.arch_icon },
    {"Libreoffice", "libreoffice", beautiful.arch_icon },
    {"Qalculate", "qalculate", beautiful.arch_icon },
}

power_menu = {
    { "Shutdown", terminal .. " -e systemctl poweroff", beautiful.arch_icon },
    { "Reboot", terminal .. " -e systemctl reboot", beautiful.arch_icon },
    { "Suspend", terminal .. " -e systemctl suspend", beautiful.arch_icon },
    { "Hibernate", terminal .. " -e systemctl hibernate", beautiful.arch_icon },
    { "Lock", "xtrlock", beautiful.arch_icon },
}

mymainmenu = awful.menu({ items = {
    { "awesome", myawesomemenu, beautiful.arch_icon },
    { "open terminal", terminal, beautiful.arch_icon },
    { "Office", office_menu, beautiful.arch_icon },
    { "Exit", power_menu, beautiful.arch_icon }, 
}})

mylauncher = awful.widget.launcher({ image = beautiful.arch_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
