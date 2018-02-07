## awesome.volume-control

Volume indicator+control widget for awesome window manager.

![Screenshot](/screenshot.png?raw=true "Screenshot")

### Installation

Simply drop the script into your awesome config folder, e.g.:

```bash
cd ~/.config/awesome
git clone https://github.com/deficient/volume-control.git
```

I recommend to also install the following:

```bash
pacman -S pavucontrol       # open volume manager with middle/right click
pacman -S acpid             # instant status updates (acpi_listen)
systemctl enable acpid
```


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
-- load the widget code
local volume_control = require("volume-control")


-- define your volume control, using default settings:
volumecfg = volume_control({})


-- add the widget to your wibox
...
right_layout:add(volumecfg.widget)
...


-- add key bindings
local globalkeys = awful.util.table.join(
    ...
    awful.key({}, "XF86AudioRaiseVolume", function() volumecfg:up() end),
    awful.key({}, "XF86AudioLowerVolume", function() volumecfg:down() end),
    awful.key({}, "XF86AudioMute",        function() volumecfg:toggle() end),
    ...
)
```

### Constructor

You can specify any subset of the following arguments to the constructor.
The default values are as follows:

```lua
volumecfg = volume_control({
  device  = nil,            -- e.g.: "default", "pulse"
  cardid  = nil,            -- e.g.: 0, 1, ...
  channel = "Master",
  step    = '5%',           -- step size for up/down
  lclick  = "toggle",       -- mouse actions described below
  mclick  = "pavucontrol",
  rclick  = "pavucontrol",
  widget  = nil,            -- use this instead of creating a awful.widget.textbox
  font    = nil,            -- font used for the widget's text
  callback = nil,           -- called to update the widget: `callback(self, state)`
})
```

Try, `device="pulse"` if having problems.

### Mouse actions

The easiest way to customize what happens on left/right/middle click is to
specify additional arguments to the constructor. These can be of any of the
following kinds:

- name of a member function: `"up"`, `"down"`, `"toggle"`, `"mute"`, `"get"`
- command string to execute
- a callable that will be called with the volume control as first parameter

E.g.:

```lua
volumecfg = volume_control({
  lclick="toggle",                        -- name of member function
  mclick=TERMINAL .. " -x alsamixer",     -- command to execute
  rclick=function(self) self:mute() end,  -- callable, equivalent to "mute"
})
```

### Icon widget

You can use the module as a basis to implement your own volume widget. For
example, an icon widget can be created as follows:

```lua
local function get_image(volume, state)
    local icondir = os.getenv("HOME") .. "/.local/share/icons/"
    if volume == 0 or state == "off"  then return icondir .. "audio_mute.png"
    elseif volume <= 33               then return icondir .. "audio_low.png"
    elseif volume <= 66               then return icondir .. "audio_med.png"
    else                                   return icondir .. "audio_high.png"
    end
end

local volume_widget = volume_control {
    tooltip = true,
    widget = wibox.widget.imagebox(),
    callback = function(self, setting)
        self.widget:set_image(
            get_image(setting.volume, setting.state))
    end,
}
```

However, in this case, I recommend to use
[pasystray](https://github.com/christophgysin/pasystray) instead.

### Requirements

* [awesome 4.0](http://awesome.naquadah.org/). May work on 3.5 with minor changes
* pavucontrol (optional)
* acpid (optional)

### Alternatives

If you like a volume control with an icon instead of text, I suggest to use
[pasystray](https://github.com/christophgysin/pasystray), which is a more
comprehensive solution and built for the systray (not awesome widget) with a
much nicer menu.
