local awful			= require("awful")
local naughty		= require("naughty")
local utils         = require("utils")
local widgets		= require("widgets")
local beautiful = require("beautiful")

local alttab = widgets.alttab
local last_focused_client = nil

local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- helper function to detect a client is floated and current mode is float
function bind_move_client2tag(globalkeys)
    for i = 1, 9 do
        globalkeys = awful.util.table.join(globalkeys,
            -- move to tag
            awful.key({ modkey  }, "#" .. i + 9, function ()
                awful.screen.focused().tags[i]:view_only()
            end),
            -- move current active window to specific tag
            awful.key({ modkey, "Control"  }, "#" .. i + 9, function ()
                if client.focus and awful.screen.focused().tags[i] then
                    client.focus:move_to_tag(awful.screen.focused().tags[i])
                end
            end)
        )
    end
    root.keys(globalkeys)
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- window navigation
    -- Toggle show desktop (for current tag(s))
    awful.key({ modkey,           }, "d",
    function ()
        local allminimized
        local c
        local clients
        clients = client.get(mouse.screen)
        for y, c in pairs(clients) do
            if(c.type ~= "desktop") then
                if c.minimized == false then
                    allminimized = false
                    break
                else
                    allminimized = true
                end
            end
        end

        if client.focus and client.focus.type ~= "desktop" then
            last_focused_client = client.focus
        end

        -- If at least one client isn't minimized, minimize all clients
        for y, c in pairs(clients) do
            -- ignore desktop window such as:xfdesktop
            if(c.type ~= "desktop") then
                if allminimized == false then
                    c.minimized = true 
                elseif allminimized == true then
                    c.minimized = false 
                end
            end
        end
        if allminimized and last_focused_client then
            client.focus = last_focused_client
            last_focused_client:raise()
            last_focused_client = nil
        end
    end),
    -- add new tag
    awful.key({ modkey,         }, "t",      function ()
        local current_tag = mouse.screen.selected_tag
        local all_tags = awful.screen.focused().tags
        local tag_num = #all_tags + 1
        tagobj = awful.tag.add(tag_num, {layout = awful.layout.suit.tile})
        awful.tag.setscreen(mouse.screen, tagobj)
        bind_move_client2tag(globalkeys)
    end),
    -- remove current tag, NOTE: current tag must contains NO clients
    awful.key({ modkey,          }, "x",      function ()
        -- we can not remove last tag
        if #awful.tag.gettags(mouse.screen) ~= 1 then
            local current_tag = mouse.screen.selected_tag
            if awful.tag.delete(current_tag) == nil then
                naughty.notify({ text = "当前工作区不为空!",
                        timeout = 1,
                        position = "top_left",
                        screen = mouse.screen
                })
            else
                local all_tags = awful.tag.gettags(mouse.screen)
                for s = 1, #all_tags do
                    if tonumber(all_tags[s].name) then
                        all_tags[s].name = s
                    end
                end
                bind_move_client2tag(globalkeys)
            end
        else
			naughty.notify({
					text = "不能移除最后一个工作区!",
					timeout = 1,
					position = "top_left",
					screen = mouse.screen
			})
        end
    end),
    awful.key({ modkey,         }, "r",    function ()
        awful.prompt.run {
            prompt = "Renname:",
            textbox = mypromptbox[awful.screen.focused().index].widget,
            exe_callback = function(new_name)
                awful.tag.selected().name = new_name
            end
        }
    end),
    awful.key({ modkey,         }, "-",    function ()
        local screengeom = screen[mouse.screen].geometry
        local cg = client.focus:geometry()
        if cg['width'] > (screengeom['width']*30/100) and cg['height'] > (screengeom['height']*30/100) then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] - delta
            cg['height'] = cg['height'] - delta_height
            client.focus:geometry(cg)
            client.focus.maximized_horizontal = false
            client.focus.maximized_vertical = false
            awful.placement.centered(client.focus, nil)
        end
    end),
    awful.key({ modkey,         }, "=",    function ()
        local screengeom = screen[mouse.screen].geometry
        local cg = client.focus:geometry()
        if (cg['width']+20)<screengeom['width'] and (cg['height']+20)<screengeom['height'] then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] + delta
            cg['height'] = cg['height'] + delta_height
            client.focus:geometry(cg)
            client.focus.maximized_horizontal = false
            client.focus.maximized_vertical = false
            awful.placement.centered(client.focus, nil)
        end
    end),
    -- center or maxmize a client
    awful.key({modkey,						}, "c", function()
        utils.center_window(client.focus)
    end),
    ------------------------------------------------------------------------------
    awful.key({ modkey, "Control"}, "c",   function()
        local screengeom = screen[mouse.screen].workarea
        local cg = client.focus:geometry()
        cg['width'] = screengeom['width']/2 - beautiful.border_width * 2
        cg['height'] = screengeom['height'] - beautiful.border_width * 2
        cg['x'] = screengeom['x'] + cg['width'] / 2
        cg['y'] = screengeom['y']
        client.focus:geometry(cg)
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = false
    end),
    awful.key({ modkey,           }, "Left",   function()
        local screengeom = screen[mouse.screen].workarea
        local cg = client.focus:geometry()
        cg['width'] = screengeom['width']/2 - beautiful.border_width * 2
        cg['height'] = screengeom['height'] - beautiful.border_width * 2
        cg['x'] = screengeom['x']
        cg['y'] = screengeom['y']
        client.focus:geometry(cg)
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = false
    end),
    awful.key({ modkey,           }, "Right",  function()
        local screengeom = screen[mouse.screen].workarea
        local cg = client.focus:geometry()
        cg['width'] = screengeom['width']/2 - beautiful.border_width * 2
        cg['height'] = screengeom['height'] - beautiful.border_width * 2
        cg['x'] = screengeom['x'] + cg['width'] + beautiful.border_width * 2
        cg['y'] = screengeom['y']
        client.focus:geometry(cg)
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = false
    end),
    awful.key({ modkey,           }, "Up",  function()
        local screengeom = screen[mouse.screen].workarea
        local cg = client.focus:geometry()
        cg['width'] = screengeom['width'] - beautiful.border_width * 2
        cg['height'] = screengeom['height']/2 - beautiful.border_width * 2
        cg['x'] = screengeom['x']
        cg['y'] = screengeom['y']
        client.focus:geometry(cg)
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = false
    end),
    awful.key({ modkey,           }, "Down",  function()
        local screengeom = screen[mouse.screen].workarea
        local cg = client.focus:geometry()
        cg['width'] = screengeom['width'] - beautiful.border_width * 2
        cg['height'] = screengeom['height']/2 - beautiful.border_width * 2
        cg['x'] = screengeom['x']
        cg['y'] = screengeom['y'] + cg['height'] + beautiful.border_width * 2
        client.focus:geometry(cg)
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = false
    end),
    ------------------------------------------------------------------------------
    awful.key({ modkey,           }, "Tab",
    function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift"   }, "Tab",
    function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ "Mod1",            }, "Tab",                                                      
    function ()                                                                              
        alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")                                             
    end),                                                                                           
    awful.key({ "Mod1", "Shift"    }, "Tab",                                                      
    function ()                                                                              
        alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")                                            
    end),
    -- navigate mouse cursor between screens
    awful.key({ modkey, }, "l", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, }, "h", function () awful.screen.focus_relative(-1) end),
    -- Standard program
    awful.key({ modkey,           }, "Return",
    function ()
        local screengeom = screen[mouse.screen].geometry
        local xoff = beautiful.margin_horizontal/2 - beautiful.border_width
        local yoff = beautiful.margin_vertical/2 - beautiful.border_width
        -- for geometry of terminator see 'man 7 X' document
        local terminal = "terminator --geometry="..(math.floor(screengeom.width) - beautiful.margin_horizontal).."x"..(math.floor(screengeom.height) - beautiful.margin_vertical).."+"..math.floor(xoff).."+"..math.floor(yoff)
        awful.spawn(terminal) 
    end),
    -- change layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    -- restart & quit awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control"   }, "q", awesome.quit),
    -- User Defined Hot Key
    awful.key({ modkey}, "e", function () awful.spawn.with_shell("thunar") end), -- yaourt -S thunar
    awful.key({ modkey}, "s", function () awful.spawn.with_shell("xfce4-screenshooter") end), -- yaourt -S xfce4-screenshooter
    awful.key({ modkey}, "i", function () awful.spawn.with_shell("chromium") end), -- yaourt -S chromium
    awful.key({ }, "XF86Calculator", function () awful.spawn.with_shell("gnome-calculator") end),
    awful.key({ modkey}, "y", function () awful.spawn.with_shell("gnome-calculator") end), -- an GUI caculate, yaourt -S gnome-calculator
    awful.key({ modkey}, "p", function () awful.spawn.with_shell("arandr") end), -- multi monitor selector like windows hotkey, yaourt -S lxrandr
    awful.key({ "Mod1", "Control"}, "space", function ()
        local geometry = screen[mouse.screen].geometry
        local cmd = "gmrun -g +" .. math.floor(geometry.x + geometry.width/2 - (beautiful.border_width + 610/2)) .. "+" .. math.floor(geometry.y  + geometry.height/2 - (beautiful.border_width + 76/2))
        awful.spawn.with_shell(cmd)
    end), -- start a notepad
    awful.key({ modkey}, "n", function () awful.spawn.with_shell("subl3") end), -- start a notepad
    awful.key({ modkey, "Control"}, "l", function () awful.spawn.with_shell("dm-tool lock &") end) -- yaourt -S lightdm lightdm-gtk-greeter
)
--end of globalkeys

-- client window hotkeys
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "z",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "t",      function (c) c.ontop = not c.ontop            end),
    -- move window to next/pre screen
    awful.key({ modkey,           }, ",",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index - 1 > 0 then
                awful.client.movetoscreen(c,c.screen.index-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = c.screen.geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ",",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index - 1 > 0 then
                awful.client.movetoscreen(c,c.screen.index-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = c.screen.geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end),
    awful.key({ modkey,           }, ".",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen.index+1)
            end
            local new_sg = c.screen.geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ".",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen.index+1)
            end
            local new_sg = c.screen.geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end),
    awful.key({ modkey,         }, "m",    function (c)
        c.minimized = true
    end)
)
--end of clientkeys

root.keys(globalkeys)
