------------------------------------------------------------------------
-- Caster.lua
-- @version 1.0.0
------------------------------------------------------------------------

--[[
    ~0.15 microseconds per cast creation
    ~1.3 microseconds per cast step
    ~120 bytes per cast
]]

local _t = require(script.Parent._typedefs)

-- import cast lib
local cast = require(script.Parent.cast)

type Caster = _t.Caster; local Caster = {} do
    type Cast = _t.Cast

    local CasterClass = {__metatable = "Locked"}
    CasterClass.__index = CasterClass

    local DEFAULT_RAYCAST_PARAMS = RaycastParams.new()

    -- runservice event
    local stepped: RBXScriptSignal = game:GetService("RunService").Heartbeat
    -- runservice event connection ref
    local connection: RBXScriptConnection? = nil

    -- creates copy of a RaycastParams instance
    local function cloneRaycastParams(params: RaycastParams): RaycastParams
        local copy: RaycastParams = RaycastParams.new()

        copy.FilterDescendantsInstances 	= params.FilterDescendantsInstances
        copy.FilterType                     = params.FilterType
        copy.IgnoreWater 				    = params.IgnoreWater
        copy.CollisionGroup 			    = params.CollisionGroup

        return copy
    end

    -- default function to assign for Caster events
    local function default(): boolean
        return false
    end

    -- cache function refs
    local create = cast.create
    local addVelocity = cast.addVelocity
    local getUserData = cast.getUserData
    local terminate = cast.terminate

    -- executed on each projectile update
    local function castStepped(id: Cast, dt: number, result: RaycastResult?)
        -- get cast's caster
        local caster = getUserData(id).Caster

        if result then
            -- determine if can pierce
            local pierced: boolean = caster.CanPierce(id, result)
            if pierced == false then
                caster.Hit(id, result)
                caster.Terminating(id)
                terminate(id)
                return
            end
            caster.Pierced(id, result)
        end

        caster.Stepped(id, dt)

        -- accelerate cast
        addVelocity(id, caster.Acceleration*dt)
    end

    function Caster.new(): Caster
        -- caster module is required by RDL by default
        -- add check to avoid unecessary cpu usage and binding if caster is never used
        if connection == nil then
            cast.bindToStepped(castStepped)
            connection = stepped:Connect(cast.simulate)
        end

        return setmetatable({
            Acceleration = Vector3.zero,
            RaycastParams = DEFAULT_RAYCAST_PARAMS,
            CanPierce = default,

            Stepped = default,
            Pierced = default,
            Hit = default,
            Terminating = default
        }, CasterClass) :: any
    end

    function CasterClass:Fire(origin: Vector3, velocity: Vector3): Cast
        return create(origin, velocity, self.RaycastParams, {Caster = self})
    end

    function CasterClass:CloneRaycastParams(): RaycastParams
        return cloneRaycastParams(self.RaycastParams)
    end

    function CasterClass:Terminate(id: Cast)
        self.Terminating(id)
        terminate(id)
    end

    function CasterClass:__tostring(): string
        return "Caster"
    end

    table.freeze(Caster)
end

return Caster
