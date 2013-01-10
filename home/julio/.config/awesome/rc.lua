-- AwesomeWM configuration file
-- Author: Julio B. Silva <julio[at]juliobs.com>

-- {{{ Libraries
-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")
-- }}}

-- add the current directory to the package path so we can relative require
-- other sections of config
package.path = "../?.lua;" .. package.path

-- {{ require config sections
require("error_handling")
require("defaults")
require("layouts")
require("tags")
require("wallpaper")
require("menu")
require("taskbar")
require("mouse_bindings")
require("keyboard_bindings")
require("rules")
require("signals")
-- }}
