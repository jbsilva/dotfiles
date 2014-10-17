-- {{{ Fix

-- Disable cursor animation:
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- Java GUI's fix:
awful.util.spawn_with_shell("wmname LG3D")

-- }}}
