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

### Known issues

One common pitfall is using the wrong sound device. On systems with pulseaudio,
it's usually best to create the control with:

```lua
volumecfg = volume_control {device="pulse"}
```

On some systems, clicking the widget will mute audio, however clicking it again
will only unmute *Master* while leaving other subsystems (Speaker, …) muted,
see e.g. [#10](https://github.com/deficient/volume-control/pull/10). This may
be fixed by setting the device to *pulse*, as described above.

If you have the `listen` enabled, unplugging USB headphones sometimes causes the
process that monitors for audio status changes (`alsactl monitor`) to spin at
100% CPU, see [#11](https://github.com/deficient/volume-conrtol/issues/11). When
this happens, you can safely kill the process or restart awesome (`Mod4 +
Control + R`). As of yet, there is no known fix other than setting
`listen=false`.

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
  listen  = false,          -- enable/disable listening for audio status changes
  widget  = nil,            -- use this instead of creating a awful.widget.textbox
  font    = nil,            -- font used for the widget's text
  callback = nil,           -- called to update the widget: `callback(self, state)`
  widget_text = {
    on  = '% 3d%% ',        -- three digits, fill with leading spaces
    off = '% 3dM ',
  },
  tooltip_text = [[
Volume: ${volume}% ${state}
Channel: ${channel}
Device: ${device}
Card: ${card}]],
})
```

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
