------------------------------------------------------------------------
-- ScriptSignal.lua
-- @version 1.0.0
------------------------------------------------------------------------

local _t = require(script.Parent._typedefs)

type ScriptSignal<T...> = _t.ScriptSignal<T...>; local ScriptSignal = {} do
    type Array<T> = {[number]: T}
    type EventHandler<T...> = (T...) -> ()

    -- using arrays to reduce memory usage
    local NEXT = 1 -- connection objects double as linked lists, signal object references head of list
    local CALLBACK = 2

    type ScriptConnection = _t.ScriptConnection; local ConnectionClass = {} do
        ConnectionClass.__metatable = "Locked"
        ConnectionClass.__index = ConnectionClass

        function ConnectionClass.IsConnected(self: ScriptConnection): boolean
            return self[CALLBACK] and true or false
        end

        --  removal handled in ScriptSignal::Fire
        function ConnectionClass.Disconnect(self: ScriptConnection)
            self[CALLBACK] = nil
        end

        function ConnectionClass:__tostring()
            return "ScriptSignal"
        end
    end

    -- free looped runner
    local freerunner: thread?

    -- event handler takes ownership of the runner thread and returns ownership when complete
    local function runEventHandler<T...>(fn: EventHandler<T...>, ...: T...)
        local runner: thread = freerunner :: thread
        freerunner = nil
        fn(...)
        freerunner = runner
    end

    -- looped event handler runner
    local function newrunner<T...>(fn: EventHandler<T...>, ...: T...)
        runEventHandler(fn, ...)
        repeat until runEventHandler( coroutine.yield() )
    end

    local SignalClass = {__metatable = "Locked"}
    SignalClass.__index = SignalClass

    function ScriptSignal.new<T...>(): ScriptSignal<T...>
        return setmetatable({}, SignalClass) :: any
    end

    function SignalClass.Connect<T...>(self: ScriptSignal<T...>, fn: EventHandler<T...>): ScriptConnection
        if type(fn) ~= "function" then
            error(string.format("Invalid argument #1 to \"ScriptSignal::Connect\" (function expected, got %s)", type(fn)), 2)
        end

        local connection: ScriptConnection = setmetatable({self[NEXT], fn}, ConnectionClass) :: any
        self[NEXT] = connection -- insert connection as head of list

        return connection
    end

    --[[
    function SignalClass:ConnectParallel();
    ]]

    function SignalClass.Wait<T...>(self: ScriptSignal<T...>): T...
        local current: thread = coroutine.running()
        local c: ScriptConnection; c = self:Connect(function(...: T...)
            c:Disconnect()
            local success: boolean, error_msg: string? = coroutine.resume(current, ...)
            if success == false then error(error_msg, 0) end
        end)
        return coroutine.yield()
    end

    function SignalClass.Fire<T...>(self: ScriptSignal<T...>, ...: T...)
        local prev_connection: ScriptConnection = self :: any
        local connection: ScriptConnection? = self[NEXT]
        while connection ~= nil do
            local callback: EventHandler<T...>? = connection[CALLBACK]
            if callback == nil then
                prev_connection[NEXT] = connection[NEXT] -- remove current connection from list
            else
                if freerunner == nil then freerunner = coroutine.create(newrunner) end
                local success: boolean, error_msg: string? = coroutine.resume(freerunner :: thread, callback, ...)
                if success == false then error(error_msg, 2) end
            end
            prev_connection = connection
            connection = connection[NEXT]
        end
    end

    function SignalClass.DisconnectAll<T...>(self: ScriptSignal<T...>)
        self[NEXT] = nil
    end

    function SignalClass:__tostring()
        return "RDLScriptSignal"
    end

    table.freeze(ScriptSignal)
end

return ScriptSignal