-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Google-chrome" };
   	properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
   	properties = { tag = tags [1][1] } },
    { rule = { class = "ncmpcpp" },
   	properties = { tag = tags [1][9] } },
    { rule = { class = "Thunderbird" },
   	properties = { tag = tags [1][8] } },
}
-- }}}