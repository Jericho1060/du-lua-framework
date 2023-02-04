--[[
    DU-Nested-Coroutines by Jericho
    Permit to easier avoid CPU Load Errors by using nested coroutines and adapt cycles on the FPS
    Source unminified available here: https://github.com/Jericho1060/du-nested-coroutines
]]--

local print = system.print
local n_error = error
local n_pcall = pcall
local n_assert = assert
local cor = coroutine
local co_create = cor.create
local co_status = cor.status
local co_resume = cor.resume
local co_status_dead = "dead"
local co_status_suspended = "suspended"

function runFunction(fn, errorPrefix, ...)
    local s, err = n_pcall(fn, ...)
    if not s then
        n_error(errorPrefix .. err)
    end
end

local DU_System = {
    __index = {
        cos = {
            update = {},
            flush = {}
        },
        fns = {
            update = {},
            flush = {},
            action = {
                start = {},
                stop = {},
                loop = {}
            },
            inputText = nil,
            start = nil,
            stop = nil
        },
        ACTIONS = {
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
        },
        main = {
            update = co_create(function() end),
            flush = co_create(function() end),
        },
        update = function(self)
            local status = co_status(self.main.update)
            if status == co_status_dead then
                self.main.update = co_create(function() self:runUpdate() end)
            elseif status == co_status_suspended then
                n_assert(co_resume(self.main.update))
            end
        end,
        flush = function(self)
            local status = co_status(self.main.flush)
            if status == co_status_dead then
                self.main.flush = co_create(function() self:runFlush() end)
            elseif status == co_status_suspended then
                n_assert(co_resume(self.main.flush))
            end
        end,
        action = function(self, event, action)
            if self.fns.action[event][action] then
                runFunction(self.fns.action[event][action], "System Action " .. event .. " Error: ")
            end
        end,
        actionStart = function(self, action)
            self:action('start', action)
        end,
        actionStop = function(self, action)
            self:action('stop', action)
        end,
        actionLoop = function(self, action)
            self:action('loop', action)
        end,
        inputText = function(self, text)
            if self.fns.inputText then
                runFunction(self.fns.inputText, "System Input Text Error: ", text)
            end
        end,
        runUpdate = function(self)
            for k,co in pairs(self.cos.update) do
                local s = co_status(co)
                if s == co_status_dead then
                    self.cos.update[k] = co_create(self.fns.update[k])
                elseif s == co_status_suspended then
                    n_assert(co_resume(co))
                end
            end
        end,
        runFlush = function(self)
            for k,co in pairs(self.cos.flush) do
                local s = co_status(co)
                if s == co_status_dead then
                    self.cos.flush[k] = co_create(self.fns.flush[k])
                elseif s == co_status_suspended then
                    n_assert(co_resume(co))
                end
            end
        end,
        onUpdate = function(self, fns)
            for k,f in pairs(fns) do
                self.fns.update[k] = f
                self.cos.update[k] = co_create(f)
            end
        end,
        onFlush = function(self, fns)
            for k,f in pairs(fns) do
                self.fns.flush[k] = f
                self.cos.flush[k] = co_create(f)
            end
        end,
        onAction = function(self, event, fns)
            for k,f in pairs(fns) do
                self.fns.action[event][k] = f
            end
        end,
        onActionStart = function(self, fns)
            self:onAction("start", fns)
        end,
        onActionStop = function(self, fns)
            self:onAction("stop", fns)
        end,
        onActionLoop = function(self, fns)
            self:onAction("loop", fns)
        end,
        onInputText = function(self, fn)
            self.fns.inputText = fn
        end
    }
}

local DU_Unit = {
    __index = {
        timers = {},
        stopFn = function() end,
        timer = function (self, tag)
            if self.timers[tag] then
                runFunction(self.timers[tag], "Unit Timer " .. tag .. " Error: ")
            end
        end,
        setTimer = function(self, tag, seconds, fn)
            self.timers[tag] = fn
            unit.setTimer(tag, seconds)
        end,
        stopTimer = function(self, tag)
            unit.stopTimer(tag)
            self.timers[tag]=nil
        end,
        onStop = function (self, fn)
            self.stopFn = fn
        end,
        stop = function(self)
            if self.stopFn then
                runFunction(self.stopFn, "Unit Stop Error: ")
            end
        end
    }
}

local DU_Player = {
    __index = {
        parentChangedFn = function(oldId, newId) end,
        onParentChange = function (self, fn)
            self.parentChangedFn = fn
        end,
        parentChanged = function (self, oldId, newId)
            if self.parentChangedFn then
                runFunction(self.parentChangedFn, "Player Parent Changed Error: ", oldId, newId)
            end
        end,
    }
}

local DU_Construct = {
    __index = {
        dockedFn = function(id) end,
        onDocked = function (self, fn)
            self.dockedFn = fn
        end,
        docked = function (self, id)
            if self.dockedFn then
                runFunction(self.dockedFn, "Construct Docked Error: ", id)
            end
        end,
        undockedFn = function(id) end,
        onUndocked = function (self, fn)
            self.undockedFn = fn
        end,
        undocked = function (self, id)
            if self.undockedFn then
                runFunction(self.undockedFn, "Construct Undocked Error: ", id)
            end
        end,
        playerBoardedFn = function(id) end,
        onPlayerBoarded = function (self, fn)
            self.playerBoardedFn = fn
        end,
        playerBoarded = function (self, id)
            if self.playerBoardedFn then
                runFunction(self.playerBoardedFn, "Construct Player Boarded Error: ", id)
            end
        end,
        VRStationEnteredFn = function(id) end,
        onVRStationEntered = function (self, fn)
            self.VRStationEnteredFn = fn
        end,
        VRStationEntered = function (self, id)
            if self.VRStationEnteredFn then
                runFunction(self.VRStationEnteredFn, "Construct VR Station Entered Error: ", id)
            end
        end,
        constructDockedFn = function(id) end,
        onConstructDocked = function (self, fn)
            self.constructDockedFn = fn
        end,
        constructDocked = function (self, id)
            if self.constructDockedFn then
                runFunction(self.constructDockedFn, "Construct Construct Docked Error: ", id)
            end
        end,
        PvPTimerFn = function(active) end,
        onPvPTimer = function (self, fn)
            self.PvPTimerFn = fn
        end,
        PvPTimer = function (self, active)
            if self.PvPTimerFn then
                runFunction(self.PvPTimerFn, "Construct PvP Timer Error: ", active)
            end
        end,
    }
}

DU_Framework = {
    __index = {
        system = setmetatable({}, DU_System),
        unit = setmetatable({}, DU_Unit),
        player = setmetatable({}, DU_Player),
        construct = setmetatable({}, DU_Construct),
    }
}
Script = {}
setmetatable(Script, DU_Framework)

--[[
    You can declare here all the functions you want to call in the diffent events from system, unit, player and construct.
    Major changes compared to the base game concept:
        - System onUpdate and onFlush events are now builded with coroutines, in the framework, onUpdate and onFlush are loading a table of functions that will be runned as coroutines. This way you can have multiple functions running at the same time, and you use the yield function to pause the coroutine and let the other coroutines run. Each coroutine will be resume or restarted if dead each time the system onUpdate or onFlush event is called.

]]

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