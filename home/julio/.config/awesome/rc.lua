-- AwesomeWM configuration file
-- Author: Julio B. Silva <julio[at]juliobs.com>

-- {{{ Libraries
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- }}}

-- add the current directory to the package path so we can relative require
-- other sections of config
package.path = "../?.lua;" .. package.path

-- {{ require config sections
require("error_handling")
require("defaults")
require("tags")
require("menu")
require("taskbar")
require("mouse_bindings")
require("keyboard_bindings")
require("rules")
require("signals")
-- }}
