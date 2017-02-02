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

By default

- *left-click* will toggle mute
- *middle-* and *right-click* will start `pavucontrol`

The easiest way to customize these actions is to specify additional arguments
to the constructor, e.g.:

```lua
volumecfg = volume_control({
  channel="Master",
  lclick=function(self) self:toggle() end,
  mclick=TERMINAL .. " -x alsamixer",   -- command to execute
  rclick="mute",                        -- name of member function
})
```


### Requirements

* [awesome 3.5](http://awesome.naquadah.org/)
