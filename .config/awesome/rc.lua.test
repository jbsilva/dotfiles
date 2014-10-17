-- AwesomeWM configuration file
-- Author: Julio Batista Silva <julio[at]juliobs.com>
-- Base: /etc/xdg/awesome/rc.lua

-- {{{ Libraries
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
wibox = require("wibox")
beautiful = require("beautiful")
vicious = require("vicious")
lain = require("lain")
naughty = require("naughty")
menubar = require("menubar")
---}}}

-- add current directory to path so we can require other sections of the config
package.path = "../?.lua;" .. package.path

-- {{ require config sections
require("_error_handling")
require("_fix")
require("_variable_definitions")
require("_wallpaper")
require("_tags")
require("_menu")
require("_widgets")
require("_wibox")
require("_mouse_bindings")
require("_key_bindings")
require("_rules")
require("_signals")
-- }}
