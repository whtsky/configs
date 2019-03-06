local awful			= require("awful")
awful.rules			= require("awful.rules")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local naughty		= require("naughty")

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, function(c)
        awful.mouse.client.move(c)
        c:raise()
    end),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            screen = function(c)
                return awesome.startup and c.screen or awful.screen.focused()
            end,
            geometry = function(c)
                return c:geometry()
            end,
            keys = clientkeys,
            buttons = clientbuttons 
        } ,
    },
    { 
        rule = { class = "Xfdesktop"  },
        except = {class = "Xfdesktop-settings"},
        properties = {
            border_width = 0,
            maximized = true,
            sticky = true,
            focusable = false,
            floating = false,
            screen = function(c)
                -- xfdesktop has some problem when there has more
                --  then one screen, and each screen has different
                --  resolution
                -- make xfdesktop on screen
                --  which has smaller resolution
                local index = 1
                for i = 1, screen:count(), 1 do
                    if screen[i].geometry.width < screen[index].geometry.width then
                        index = i
                    end
                end
                return screen[index]
            end,
        }
    },
    {
    	rule = { class = "Popup" },
    	properties = { border_width = 0, no_border = true },
    },
    {
    	rule = { class = "Wine" },
    	properties = { floating = true, border_width = 0, no_border = true },
    },
    {
    	rule = { class = "deepin-voice-recorder" },
    	properties = { border_width = 0, no_border = true },
    },
}
