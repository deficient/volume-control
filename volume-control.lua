local awful = require("awful")
local wibox = require("wibox")

-- Volume Control

-- vcontrol.mt: module (class) metatable
-- vcontrol.wmt: widget (instance) metatable
local vcontrol = { mt = {}, wmt = {} }
vcontrol.wmt.__index = vcontrol


------------------------------------------
-- Private utility functions
------------------------------------------

local function readcommand(command)
    local file = io.popen(command)
    local text = file:read('*all')
    file:close()
    return text
end

local function quote(str)
    return "'" .. string.gsub(str, "'", "'\\''") .. "'"
end

local function arg(first, ...)
    if #{...} == 0 then
        return quote(first)
    else
        return quote(first), arg(...)
    end
end

local function argv(...)
    return table.concat({arg(...)}, " ")
end


------------------------------------------
-- Volume control interface
------------------------------------------

function vcontrol.new(args)
    local sw = setmetatable({}, vcontrol.wmt)

    sw.cmd = "amixer"
    sw.cardid  = args.cardid or nil
    sw.channel = args.channel or "Master"
    sw.step = args.step or '5%'

    sw.widget = wibox.widget.textbox()
    sw.widget.set_align("right")

    sw.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() sw:toggle() end),
        awful.button({ }, 3, function() sw:toggle() end),
        awful.button({ }, 4, function() sw:up() end),
        awful.button({ }, 5, function() sw:down() end)
    ))

    sw.timer = timer({ timeout = args.timeout or 10 })
    sw.timer:connect_signal("timeout", function() sw:get() end)
    sw.timer:start()
    sw:get()

    return sw
end

function vcontrol:update(status)
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

function vcontrol:mixercommand(...)
    local command
    if self.cardid == nil then
        command = argv(self.cmd, ...)
    else
        command = argv(self.cmd, "-c", self.cardid, ...)
    end
    return readcommand(command)
end

function vcontrol:get()
    self:update(self:mixercommand("get", self.channel))
end

function vcontrol:up()
    self:update(self:mixercommand("set", self.channel, self.step .. "+"))
end

function vcontrol:down()
    self:update(self:mixercommand("set", self.channel, self.step .. "-"))
end

function vcontrol:toggle()
    self:update(self:mixercommand("set", self.channel, "toggle"))
end

function vcontrol:mute()
    self:update(self:mixercommand("set", "Master", "mute"))
end

function vcontrol.mt:__call(...)
    return vcontrol.new(...)
end

return setmetatable(vcontrol, vcontrol.mt)

