-- Volume Control
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")


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

local function table_map(func, tab)
    local result = {}
    for i, v in ipairs(tab) do
        result[i] = func(v)
    end
    return result
end

local function make_argv(args)
    return table.concat(table_map(quote_arg, args), " ")
end


------------------------------------------
-- Volume control interface
------------------------------------------

local vcontrol = {}

function vcontrol:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function vcontrol:init(args)
    self.cmd = "amixer"
    self.device = args.device or nil
    self.cardid  = args.cardid or nil
    self.channel = args.channel or "Master"
    self.step = args.step or '5%'
    self.lclick = args.lclick or "toggle"
    self.mclick = args.mclick or "pavucontrol"
    self.rclick = args.rclick or "pavucontrol"
    self.widget_text = {
        on  = '% 3d%% ',
        off = '% 3dM ',
    }

    self.widget = wibox.widget.textbox()
    self.widget.set_align("right")

    self.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function() self:action(self.lclick) end),
        awful.button({}, 2, function() self:action(self.mclick) end),
        awful.button({}, 3, function() self:action(self.rclick) end),
        awful.button({}, 4, function() self:up() end),
        awful.button({}, 5, function() self:down() end)
    ))

    self.timer = gears.timer({ timeout = args.timeout or 0.5 })
    self.timer:connect_signal("timeout", function() self:get() end)
    self.timer:start()
    self:get()

    return self
end

function vcontrol:action(action)
    if self[action]                   then self[action](self)
    elseif type(action) == "function" then action(self)
    elseif type(action) == "string"   then awful.spawn(action)
    end
end

function vcontrol:update(status)
    local volume = status:match("(%d?%d?%d)%%")
    local state  = status:match("%[(o[nf]*)%]")
    if volume and state then
        self.widget:set_text(
            self.widget_text[state]:format(volume))
    end
end

function vcontrol:mixercommand(...)
    local args = awful.util.table.join(
      {self.cmd},
      self.device and {"-D", self.device} or {},
      self.cardid and {"-c", self.cardid} or {},
      {...})
    return readcommand(make_argv(args))
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

return setmetatable(vcontrol, {
    __call = vcontrol.new,
})

