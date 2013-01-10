-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/julio/julio.lua")

-- Standard programs
terminal        = "urxvt"
editor          = os.getenv("EDITOR") or "vim"
editor_cmd      = terminal .. " -e " .. editor
browser         = os.getenv("BROWSER") or "chromium"
guieditor       = "gvim"
file_manager    = terminal .. " -e vifm "

-- Aliases
altkey          = "Mod1"
modkey          = "Mod4"
exec            = awful.util.spawn
shell_exec      = awful.util.spawn_with_shell
-- }}}
