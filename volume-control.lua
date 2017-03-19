local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

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

local function quote_arg(str)
    return "'" .. string.gsub(str, "'", "'\\''") .. "'"
end

local function quote_args(first, ...)
    if #{...} == 0 then
        return quote_arg(first)
    else
        return quote_arg(first), quote_args(...)
    end
end

local function make_argv(...)
    return table.concat({quote_args(...)}, " ")
end


------------------------------------------
-- Volume control interface
------------------------------------------

function vcontrol.new(args)
    local sw = setmetatable({}, vcontrol.wmt)

    sw.cmd = "amixer"
    sw.device = args.device or nil
    sw.cardid  = args.cardid or nil
    sw.channel = args.channel or "Master"
    sw.step = args.step or '5%'
    sw.lclick = args.lclick or "toggle"
    sw.mclick = args.mclick or "pavucontrol"
    sw.rclick = args.rclick or "pavucontrol"

    sw.widget = wibox.widget.textbox()
    sw.widget.set_align("right")

    sw.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function() sw:action(sw.lclick) end),
        awful.button({}, 2, function() sw:action(sw.mclick) end),
        awful.button({}, 3, function() sw:action(sw.rclick) end),
        awful.button({}, 4, function() sw:up() end),
        awful.button({}, 5, function() sw:down() end)
    ))

    sw.timer = gears.timer({ timeout = args.timeout or 0.5 })
    sw.timer:connect_signal("timeout", function() sw:get() end)
    sw.timer:start()
    sw:get()

    return sw
end

function vcontrol:action(action)
    if action == nil then
        return
    end
    if type(action) == "function" then
        action(self)
    elseif type(action) == "string" then
        if self[action] ~= nil then
            self[action](self)
        else
            awful.spawn(action)
        end
    end
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
    local args = awful.util.table.join(
      {self.cmd},
      self.device and {"-D", self.device} or {},
      self.cardid and {"-c", self.cardid} or {},
      {...})
    local command = make_argv(unpack(args))
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

