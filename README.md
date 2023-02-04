# du-lua-framework
 A framework to simplidy coding in Dual Universe.
 
 Permit to add create most of the code in Unit > onStart

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

System onUpdate and onFlush events are now builded with coroutines, in the framework, onUpdate and onFlush are loading a table of functions that will be runned as coroutines. This way you can have multiple functions running at the same time, and you use the yield function to pause the coroutine and let the other coroutines run. Each coroutine will be resume or restarted if dead each time the system onUpdate or onFlush event is called.

## Code Examples

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

--Function to run on actions
local system_action_start = {}
system_action_start[Script.system.ACTIONS.BRAKE] = function()
    system.print("I'm braking");
end
local system_action_stop = {}
system_action_stop[Script.system.ACTIONS.BRAKE] = function()
    system.print("I stopped braking");
end
local system_action_loop = {}
system_action_loop[Script.system.ACTIONS.BRAKE] = function()
    system.print("I'm still braking");
end

--Function to run when input text to the lua chat
local system_inputText = function (text)
    system.print("Input: " .. text)
end

--Function to run when the program is stopping
local unit_onstop = function ()
    system.print("Program is stopping")
end

--Function to run when the player change parent
local player_onparentchanged = function (oldParent, newParent)
    system.print("Player changed parent from ID "..oldParent.." to ID "..newParent)
end

--Function to run when the construct is docked or undocked
local construct_onDocked = function(id)
    system.print("Construct docked on ID "..id)
end
local construct_onUndocked = function(id)
    system.print("Construct undocked from ID "..id)
end

--Function to run when a player board the construct
local construct_onplayerboarded = function(id)
    system.print("Player with ID " .. id .. " boarded construct")
end

--Function to run when a player enter the VR Station
local construct_vrstationentered = function(id)
    system.print("Player with ID " .. id .. " entered VR Station")
end

--Function to run when another construct is docked on this construct
local construct_constructdocked = function(id)
    system.print("Construct with ID " .. id .. " docked on this construct")
end

--Function to run when pvp timer is changing state
local construct_onpvptimer = function(active)
    if active then
        system.print("PVP is now active")
    else
        system.print("PVP is now inactive")
    end
end

--[[
    Here how to load the functions in the framework
]]
Script.system:onUpdate(system_update) --loading coroutines for system > onUpdate
Script.system:onFlush(system_flush) --loading coroutines for system > onFlush

Script.system:onActionStart(system_action_start) --loading all "actionStart" functions
Script.system:onActionStop(system_action_stop) --loading all "actionStop" functions
Script.system:onActionLoop(system_action_loop) --loading all "actionLoop" functions

Script.system:onInputText(system_inputText) --loading the function to trigger when input text in lua chat

--[[
    Here how to add a timer
    @param name: the name of the timer, used to remove it with Script.unit:stopTimer(name)
    @param delay: the delay between each call of the function in seconds
    @param func: the function to call
]]
Script.unit:setTimer("hello", 1, function()system.print("hello")end) --add a timer displaying "hello" every seconds
Script.unit:setTimer("hello5", 5, function()system.print("hello 5")end) --add a timer displaying "hello 5" every 5 seconds
Script.unit:onStop(unit_onstop) --loading the function to trigger when the program is stopping

Script.player:onParentChanged(player_onparentchanged) --loading the function to trigger when the player change parent

Script.construct:onDocked(construct_onDocked) --loading the function to trigger when the construct is docked
Script.construct:onUndocked(construct_onUndocked) --loading the function to trigger when the construct is undocked
Script.construct:onPlayerBoarded(construct_onplayerboarded) --loading the function to trigger when a player board the construct
Script.construct:onVRStationEntered(construct_vrstationentered) --loading the function to trigger when a player enter the VR Station
Script.construct:onConstructDocked(construct_constructdocked) --loading the function to trigger when another construct is docked on this construct
Script.construct:onPvPTimer(construct_onpvptimer) --loading the function to trigger when pvp timer is changing state
```

## System Actions:

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
LEFT_MOUSE = "leftmouse",
STOP_ENGINES = "stopengines",
SPEED_UP = "speedup",
SPEED_DOWN = "speeddown",
ANTIGRAVITY = "antigravity",
BOOSTER = "booster"
```
