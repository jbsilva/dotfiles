-- {{{ Menu
awesome_menu = {
   { "Manual", terminal .. " -e man awesome", beautiful.arch_icon },
   { "Edit rc.lua", editor_cmd .. " " .. awesome.conffile, beautiful.arch_icon },
   { "Restart", awesome.restart, beautiful.arch_icon },
   { "Quit", awesome.quit, beautiful.arch_icon }
}

internet_menu = {
    { "Firefox", "firefox", beautiful.arch_icon },
    { "Chromium", "chromium", beautiful.arch_icon },
    { "Uzbl", "uzbl-tabbed", beautiful.arch_icon },
    { "Pidgin", "pidgin", beautiful.arch_icon },
    { "Skype", "skype", beautiful.arch_icon },
    { "Irssi", terminal .. "-e irssi", beautiful.arch_icon },
    { "Wicd", "wicd-gtk", beautiful.arch_icon },
    { "Thunderbird", "thunderbird", beautiful.arch_icon },
}

graphics_menu = {
    { "Gimp", "gimp", beautiful.arch_icon },
    { "Inkscape", "inkscape", beautiful.arch_icon },
    { "Feh", terminal .. " -e feh", beautiful.arch_icon},
    { "Gqview", "gqview", beautiful.arch_icon },
    { "Xournal", "xournal", beautiful.arch_icon },
}

dev_menu = {
    {"Eclipse", "eclipse", beautiful.arch_icon },
    {"Netbeans", function() shell_exec("wmname LG3D; netbeans") end, beautiful.arch_icon },
}

office_menu = {
    {"Gvim", "gvim", beautiful.arch_icon },
    {"Libreoffice", "libreoffice", beautiful.arch_icon },
    {"Okular", "okular", beautiful.arch_icon },
    {"Qalculate", "qalculate", beautiful.arch_icon },
}

media_menu = {
    { "ncmpcpp", terminal .. " -e ncmpcpp", beautiful.arch_icon },
    { "Vlc", "vlc", beautiful.arch_icon },
}

folders_menu = {
    { "Pcmanfm", "pcmanfm", beautiful.arch_icon },
    { " ", nil, nil },
    { "Home", file_manager .. "~", beautiful.arch_icon },
    { "Musicas", file_manager .. "/media/externo/Musicas/", beautiful.arch_icon },
    { "Imagens", file_manager .. "/media/midia/Imagens/", beautiful.arch_icon },
    { "Filmes", file_manager .. "/media/midia/Filmes/", beautiful.arch_icon },
    { "Documentos", file_manager .. "/media/midia/Documentos/", beautiful.arch_icon },
    { "Seriados", file_manager .. "/media/externo/Downloads/Torrents/seeding/Seriados/", beautiful.arch_icon },
    { "Dropbox", file_manager .. "/home/julio/Dropbox/", beautiful.arch_icon },
}

power_menu = {
    { "Shutdown", terminal .. " -e sudo shutdown -h now", beautiful.arch_icon },
    { "Reboot", terminal .. " -e sudo reboot", beautiful.arch_icon },
    { "Suspend", terminal .. " -e sudo pm-suspend", beautiful.arch_icon },
    { "Hibernate", terminal .. " -e sudo pm-hibernate", beautiful.arch_icon },
    { "Lock", "xtrlock", beautiful.arch_icon },
}

main_menu = awful.menu({ items = {
    { "awesome", awesome_menu, beautiful.arch_icon },
    { " ", nil, nil },
    { "Terminator", "terminator", beautiful.arch_icon },
    { "Urxvt", "urxvt", beautiful.arch_icon },
    { " ", nil, nil },
    { "Internet", internet_menu, beautiful.arch_icon },
    { "Graphics", graphics_menu, beautiful.arch_icon },
    { "Development", dev_menu, beautiful.arch_icon },
    { "Office", office_menu, beautiful.arch_icon },
    { "Media", media_menu, beautiful.arch_icon },
    { "Folders", folders_menu, beautiful.arch_icon },
    { " ", nil, nil },
    { "Exit", power_menu, beautiful.arch_icon }, 
}})

mylauncher = awful.widget.launcher({ 
    image = image(beautiful.arch_icon),
    menu = main_menu
})
-- }}}
