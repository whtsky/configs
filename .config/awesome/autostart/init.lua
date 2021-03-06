local require=require
local type=type
local assert=assert
local coroutine=coroutine
local tonumber=tonumber
local io=io local lfs=require("lfs") local awful=require("awful")
module("autostart")

-- {{{ Run programm once
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
        -- All directories in /proc containing a number, represent a process
        if tonumber(dir) ~= nil then
          local f, err = io.open("/proc/"..dir.."/cmdline")
          if f then
            local cmdline = f:read("*all")
            f:close()
            if cmdline ~= "" then
              coroutine.yield(cmdline)
            end
          end
        end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd, with_shell)
    assert(type(process) == "string")
    local replacer = {
        ["+"]  = "%+",
        ["-"] = "%-",
        ["*"]  = "%*",
        ["?"]  = "%?" 
    }

    for p in processwalker() do
        if p:find(process:gsub("[-+?*]", replacer)) then
            return
        end
    end
    if with_shell then
        return awful.spawn.with_shell(cmd or process)
    else
        return awful.spawn(cmd or process)
    end
end
-- }}}

run_once('xfdesktop', 'xfdesktop --disable-wm-check')
run_once('compton', 'compton')
run_once('syndaemon', 'syndaemon -t -k -i 2 -d 2>/dev/null')
run_once('indicator-keylock', 'indicator-keylock')
run_once('volumeicon', 'volumeicon')
run_once('thunar', 'thunar --daemon')
run_once('synology-note-station', 'kdocker -d 30 -i /home/hacksign/.syno_ns_app/package.nw/icon/NoteStation_32.png .syno_ns_app/launch.sh 1>/dev/null 2>&1')
run_once('nm-applet', 'nm-applet 1>/dev/null')
run_once('fcitx', 'fcitx-autostart 1>/dev/null 2>&1')
run_once('goldendict', 'goldendict')
run_once('thunderbird', 'kdocker -d 10 thunderbird')
run_once('ss-qt5', 'ss-qt5')
-- run_once('EvernoteTray', 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe" 1>/dev/null 2>&1')
-- run_once('bcloud-gui', 'bcloud-gui')
run_once('caffeine', 'caffeine')
run_once('blueman-applet', 'blueman-applet 1>/dev/null 2>&1')
-- run_once('fusuma', '/home/hacksign/.gem/ruby/2.5.0/bin/fusuma 1>/dev/null 2>&1')
run_once('/usr/bin/libinput-gestures', 'libinput-gestures-setup restart 1>/dev/null 2>&1', true)
run_once('remmina', 'remmina --icon')
