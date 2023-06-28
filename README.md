# du-lua-framework
 A framework to simplify coding in Dual Universe.
 
 Permit to create most of the code in Unit > onStart

# Edit the code Online

[![img](https://du-lua.dev/img/open_in_editor_button.png)](https://du-lua.dev/#/editor/github/Jericho1060/du-lua-framework)

# Guilded Server (better than Discord)

You can join me on Guilded for help or suggestions or requests by following that link : https://guilded.jericho.dev
 

# Support or donation

if you like it, [<img src="https://github.com/Jericho1060/DU-Industry-HUD/blob/main/ressources/images/ko-fi.png?raw=true" width="150">](https://ko-fi.com/jericho1060) or you can sponsor me directly on [Github](https://github.com/sponsors/Jericho1060)

# Documentation and examples

## How to use it

Copy the content of the file [`config.json`](https://raw.githubusercontent.com/Jericho1060/du-lua-framework/main/config.json) and paste it on any control unit by right clicking on it and selecting "Advanced" and then "Paste Lua Configuration from clipboard".

*Warning 1: It can happens that the paste is not working in DU, it'f it's your case, please, restart the game and try again.*

*Warning 2: Paste may not work in GeForce Now, please install it from a real PC or ask someone else to install it for you.*

## Major Changes compared to the game logic

System onUpdate and onFlush events are now built with coroutines, in the framework, onUpdate and onFlush are loading a table of functions that will be runned as coroutines. This way you can have multiple functions running at the same time, and you use the yield function to pause the coroutine and let the other coroutines run. Each coroutine will be resume or restarted if dead each time the system onUpdate or onFlush event is called.

## Code Examples

### System > onUpdate and onFlush


```lua
--Functions to load as coroutines that will be runned in system > onUpdate (based on FPS)
local system_update = {}
system_update.co1 = function ()
    for i=0, 10 do
        system.print("coroutine 1 --- update --- "..i)
        coroutine.yield() -- pause the coroutine 1, it will wait till the next onUpdate event to be resumed
    end
end
system_update.co2 = function ()
    for i=0, 10 do
        system.print("coroutine 2 --- update --- "..i)
        coroutine.yield() -- pause the coroutine 2, it will wait till the next onUpdate event to be resumed
    end
end

Script.system:onUpdate(system_update) --loading coroutines for system > onUpdate

--Functions to load as coroutines that will be runned in system > onFlush (60 times / s)
local system_flush = {}
system_flush.co1 = function ()
    for i=0, 10 do
        system.print("coroutine 1 --- flush --- "..i)
        coroutine.yield() -- pause the coroutine 1, it will wait till the next onFlush event to be resumed
    end
end
system_flush.co2 = function ()
    for i=0, 10 do
        system.print("coroutine 2 --- flush --- "..i)
        coroutine.yield() -- pause the coroutine 2, it will wait till the next onFlush event to be resumed
    end
end

Script.system:onFlush(system_flush) --loading coroutines for system > onFlush

```

### System > onActionStart, onActionStop and onActionLoop

```lua

--Function to run on actions
local system_action_start = {}
system_action_start[Script.system.ACTIONS.BRAKE] = function()
    system.print("I'm braking");
end
Script.system:onActionStart(system_action_start) --loading all "actionStart" functions

local system_action_stop = {}
system_action_stop[Script.system.ACTIONS.BRAKE] = function()
    system.print("I stopped braking");
end
Script.system:onActionStop(system_action_stop) --loading all "actionStop" functions

local system_action_loop = {}
system_action_loop[Script.system.ACTIONS.BRAKE] = function()
    system.print("I'm still braking");
end
Script.system:onActionLoop(system_action_loop) --loading all "actionLoop" functions

```

### System > onInputText

```lua
--Function to run when input text to the lua chat
Script.system:onInputText(function (text)
    system.print("Input: " .. text)
end)
```

### unit > onStop

```lua
--Function to run when the program is stopping
Script.unit:onStop(function()
    system.print("Program is stopping")
end)

```

### unit > Timers

```lua
--[[
    Here how to add a timer
    @param name: the name of the timer, used to remove it with Script.unit:stopTimer(name)
    @param delay: the delay between each call of the function in seconds
    @param func: the function to call
]]
Script.unit:setTimer("hello", 1, function()system.print("hello")end) --add a timer displaying "hello" every seconds
Script.unit:setTimer("hello5", 5, function()system.print("hello 5")end) --add a timer displaying "hello 5" every 5 seconds

Script.unit:stopTimer("hello") --stop the timer "hello"

```

### player > onParentChanged

```lua

--Function to run when the player change parent
Script.player:onParentChanged(function (oldParent, newParent)
    system.print("Player changed parent from ID "..oldParent.." to ID "..newParent)
end)

```

### construct events

```lua

--Function to run when the construct is docked or undocked
Script.construct:onDocked(function(id)
    system.print("Construct docked on ID "..id)
end)
Script.construct:onUndocked(function(id)
    system.print("Construct undocked from ID "..id)
end)

--Function to run when a player board the construct
Script.construct:onPlayerBoarded(function(id)
    system.print("Player with ID " .. id .. " boarded construct")
end)

--Function to run when a player enter the VR Station
Script.construct:onVRStationEntered(function(id)
    system.print("Player with ID " .. id .. " entered VR Station")
end)

--Function to run when another construct is docked on this construct
Script.construct:onConstructDocked(function(id)
    system.print("Construct with ID " .. id .. " docked on this construct")
end)

--Function to run when pvp timer is changing state
Script.construct:onPvPTimer(function(active)
    if active then
        system.print("PVP is now active")
    else
        system.print("PVP is now inactive")
    end
end)
```

### System Actions:

to use with `Script.system.ACTIONS[ActionKey]`

```lua
FORWARD = "forward",
BACKWARD = "backward",
YAW_LEFT = "yawleft",
YAW_RIGHT = "yawright",
STRAFE_LEFT = "strafeleft",
STRAFE_RIGHT = "straferight",
LEFT = "left",
RIGHT = "right",
UP = "up",
DOWN = "down",
GROUND_ALTITUDE_UP = "groundaltitudeup",
GROUND_ALTITUDE_DOWN = "groundaltitudedown",
LEFT_ALT = "lalt",
LEFT_SHIFT = "lshift",
GEAR = "gear",
LIGHT = "light",
BRAKE = "brake",
OPTION_1 = "option1",
OPTION_2 = "option2",
OPTION_3 = "option3",
OPTION_4 = "option4",
OPTION_5 = "option5",
OPTION_6 = "option6",
OPTION_7 = "option7",
OPTION_8 = "option8",
OPTION_9 = "option9",
OPTION_10 = "option10",
OPTION_11 = "option11",
OPTION_12 = "option12",
OPTION_13 = "option13",
OPTION_14 = "option14",
OPTION_15 = "option15",
OPTION_16 = "option16",
OPTION_17 = "option17",
OPTION_18 = "option18",
OPTION_19 = "option19",
OPTION_20 = "option20",
OPTION_21 = "option21",
OPTION_22 = "option22",
OPTION_23 = "option23",
OPTION_24 = "option24",
OPTION_25 = "option25",
OPTION_26 = "option26",
OPTION_27 = "option27",
OPTION_28 = "option28",
OPTION_29 = "option29",
LEFT_MOUSE = "leftmouse",
STOP_ENGINES = "stopengines",
SPEED_UP = "speedup",
SPEED_DOWN = "speeddown",
ANTIGRAVITY = "antigravity",
BOOSTER = "booster"
```
