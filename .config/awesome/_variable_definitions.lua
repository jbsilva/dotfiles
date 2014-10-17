-- {{{ Variable definitions
modkey      = "Mod4"
exec        = awful.util.spawn
shell_exec  = awful.util.spawn_with_shell

terminal    = "urxvt"
editor      = os.getenv("EDITOR") or "vim"
editor_cmd  = terminal .. " -e " .. editor
browser     = os.getenv("BROWSER") or "chromium"

-- Theme
local theme = "julio"
beautiful.init(awful.util.getdir("config") .. "/themes/" .. theme .. "/theme.lua")

-- }}}
