local awful = require("awful")
local wibox = require("wibox")

-- Volume Control

-- vcontrol.mt: module (class) metatable
-- vcontrol.wmt: widget (instance) metatable
local vcontrol = { mt = {}, wmt = {} }
vcontrol.wmt.__index = vcontrol


function readcommand(command)
    local file = io.popen(command)
    local text = file:read('*all')
    file:close()
    return text
end


function vcontrol.new(args)
    local sw = setmetatable({}, vcontrol.wmt)

    sw.cmd = "amixer"
    sw.cardid  = args.cardid or 0
    sw.channel = args.channel or "Master"

    sw.widget = wibox.widget.textbox()
    sw.widget.set_align("right")

    sw.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() sw:toggle() end),
        awful.button({ }, 3, function() sw:toggle() end),
        awful.button({ }, 4, function() sw:up() end),
        awful.button({ }, 5, function() sw:down() end)
    ))

    sw.timer = timer({ timeout = args.timeout or 10 })
    sw.timer:connect_signal("timeout", function() sw:update() end)
    sw.timer:start()
    sw:update()

    return sw
end

function vcontrol:mixercommand(command)
    local status = readcommand(command)

    local volume = string.match(status, "(%d?%d?%d)%%")
    if volume == nil then
        return
    end
    volume = string.format("% 3d", volume)
    status = string.match(status, "%[(o[^%]]*)%]")
    if string.find(status, "on", 1, true) then
        volume = volume .. "%"
    else
        volume = volume .. "M"
    end
    self.widget:set_text(volume .. " ")
end

function vcontrol:mkcmd(command)
    return "amixer -c " .. self.cardid .. " " .. command
end

function vcontrol:update()
    self:mixercommand(self:mkcmd("get " .. self.channel))
end

function vcontrol:up()
    self:mixercommand(self:mkcmd("set " .. self.channel .. " 5%+"))
end

function vcontrol:down()
    self:mixercommand(self:mkcmd("set " .. self.channel .. " 5%-"))
end

function vcontrol:toggle()
    self:mixercommand(self:mkcmd("set " .. self.channel .. " toggle"))
end

function vcontrol:mute()
    self:mixercommand(self:mkcmd("set Master mute"))
end

function vcontrol.mt:__call(...)
    return vcontrol.new(...)
end

return setmetatable(vcontrol, vcontrol.mt)

