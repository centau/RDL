------------------------------------------------------------------------
-- setInterval.lua
-- @version 1.0.0
------------------------------------------------------------------------

local heartbeat: RBXScriptSignal = game:GetService("RunService").Heartbeat

return function(period: number, callback: () -> ()): RBXScriptConnection
    local elapsed: number = 0

    return heartbeat:Connect(function(dt: number)
        local _elapsed: number = elapsed
        _elapsed += dt
        while _elapsed >= period do
            _elapsed -= period
            callback()
        end
        elapsed = _elapsed
    end)
end