## awesome.volume-control

### Description

Volume indicator+control widget for awesome window manager.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
cd ~/.config/awesome
git clone https://github.com/coldfix/awesome.volume-control.git
ln -s awesome.volume-control/volume-control.lua
```


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
-- load the widget code
local volume_control = require("volume-control")


-- define your volume control
volumecfg = volume_control({channel="Master"})


-- open alsamixer in terminal on middle-mouse
volumecfg.widget:buttons(awful.util.table.join(
    volumecfg.widget:buttons(),
    awful.button({}, 2, function() awful.util.spawn(TERMINAL .. " -x alsamixer") end)
))


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


### Requirements

* [awesome 3.5](http://awesome.naquadah.org/)
