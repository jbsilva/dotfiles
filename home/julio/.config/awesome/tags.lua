-- {{{ Tags

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,             --layouts[1]
    awful.layout.suit.tile.left,        --layouts[2]
    awful.layout.suit.tile.bottom,      --layouts[3]
    awful.layout.suit.tile.top,         --layouts[4]
    awful.layout.suit.fair,             --layouts[5]
    awful.layout.suit.fair.horizontal,  --layouts[6]
    awful.layout.suit.spiral,           --layouts[7]
    awful.layout.suit.spiral.dwindle,   --layouts[8]
    awful.layout.suit.max,              --layouts[9]
    awful.layout.suit.max.fullscreen,   --layouts[10]
    awful.layout.suit.magnifier,        --layouts[11]
    awful.layout.suit.floating          --layouts[12]
}

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({
        "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }, s, layouts[1])
end
-- }}}
