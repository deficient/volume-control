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
  rclick=function(self) self:mute() end,  -- callable, equivalent to "toggle"
})
```


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/)

Note, it might also work on awesome 3.5 if you replace:

```diff
--- a/volume-control.lua
+++ b/volume-control.lua
@@ -82,7 +82,7 @@ function vcontrol:action(action)
         if self[action] ~= nil then
             self[action](self)
         else
-            awful.spawn(action)
+            awful.util.spawn(action)
         end
     end
 end
```
