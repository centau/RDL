------------------------------------------------------------------------
-- cast.lua
-- @version 1.0.0
------------------------------------------------------------------------

--[[
    Cast library, exposes functions to interact with an ECS styled system.

    ~0.08 microseconds per cast creation
    ~1 microseconds per cast step
    ~52 bytes per cast
]]

--local _t = require(script.Parent._typedefs)

local cast do
    -- typedefs
    type Array<T> = {[number]: T}
    type id = number

    -- cache workspace global and raycast method
    local workspace = workspace
    local raycast = workspace.Raycast

    -- function to be ran after each simulation step of each projectile
    local stepped: (i: id, dt: number, result: RaycastResult?) -> nil = function() end

    -- safeguard against recursive simulations
    local simulating: boolean = false

    -- stack pointer, holds index of last projectile
    local sp: number = 0

    -- projectile components
    local POSITION:     Array<Vector3>        = {}
    local VELOCITY:     Array<Vector3>        = {}
    local RAY_PARAMS:   Array<RaycastParams?> = {}
  --local SCALAR:       Array<Vector3>        = {} -- X: distance travelled, Y: max distance, Z: runtime
    local EXTRA:        Array<any?>           = {}

    -- creates new projectile cast
    local function create(position: Vector3, velocity: Vector3, rayparams: RaycastParams?, userData: any?): id
        local _sp = sp + 1
        POSITION    [_sp] = position
        VELOCITY    [_sp] = velocity
        RAY_PARAMS  [_sp] = rayparams
        EXTRA       [_sp] = userData
        sp = _sp
        return _sp
    end

    -- get current position of cast
    local function getPosition(i: id): Vector3
        return POSITION[i]
    end

    -- set new position of cast
    local function setPosition(i: id, v: Vector3)
        POSITION[i] = v
    end

    -- get current velocity of cast
    local function getVelocity(i: id): Vector3
        return VELOCITY[i]
    end

    -- set new velocity of cast
    local function setVelocity(i: id, v: Vector3)
        VELOCITY[i] = v
    end

    -- increment cast's current velocity
    local function addVelocity(i: id, v: Vector3)
        VELOCITY[i] += v
    end

    -- get the cast's current RaycastParams instance if any
    local function getRaycastParams(i: id): RaycastParams?
        return RAY_PARAMS[i]
    end

    -- sets (or removes) the cast's raycast parameters instance
    local function setRaycastParams(i: id, params: RaycastParams?)
        RAY_PARAMS[i] = params
    end

    -- get any extra data associated with the cast (set by user)
    local function getUserData(i: id): any?
        return EXTRA[i]
    end

    local function setUserData(i: id, v: any?)
        EXTRA[i] = v
    end

    -- changes the cast's velocity based on a reflection about the normal vector
    -- returns new velocity
    -- r = d - 2(d⋅n)n; n is normalized
    local function reflect(i: id, normal: Vector3): Vector3
        local velocity = VELOCITY[i]
        velocity = (velocity - (2*velocity:Dot(normal) * normal) )
        VELOCITY[i] = velocity
        return velocity
    end

    -- terminates and clears up cast data
    local function terminate(i: id)
        local _sp = sp
        POSITION    [i] = POSITION[_sp]     ;POSITION[_sp]   = nil
        VELOCITY    [i] = VELOCITY[_sp]     ;VELOCITY[_sp]   = nil
        RAY_PARAMS  [i] = RAY_PARAMS[_sp]   ;RAY_PARAMS[_sp] = nil
        EXTRA       [i] = EXTRA[_sp]        ;EXTRA[_sp]      = nil
        sp = _sp - 1
    end

    -- terminates at the END of current resumption cycle
    local function terminateAll()
        task.defer(function()
            table.clear(POSITION)
            table.clear(VELOCITY)
            table.clear(RAY_PARAMS)
            table.clear(EXTRA)
            sp = 0
        end)
    end

    -- returns current amount of active casts
    local function getCount(): number
        return sp
    end

    -- creates a part to visualize the trajectory of a cast for a given step
    local function visualize(i: id, dt: number, parent: Instance)
        local p: Part = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = Color3.new(0, 0, 0)
        local p1: Vector3 = getPosition(i)
        local p2: Vector3 = p1 + getVelocity(i)*dt
        p.Size = Vector3.new(0.5, 0.5, (p2 - p1).Magnitude)
        p.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -p.Size.Z)
        p.Parent = parent
    end

    -- sets the function to be ran for each projectile step
    local function bindToStepped(fn: (i: id, dt: number, result: RaycastResult?) -> nil)
        stepped = fn
    end

    -- advances simulation of all casts by a given timestep
    local function simulate(dt: number)
        if simulating == true then 
            error("Simulation already in progress", 2)
        end
        -- bring components into function scope to avoid upvalue reading
        local _POSITION   = POSITION
        local _VELOCITY   = VELOCITY
        local _RAY_PARAMS = RAY_PARAMS
        local _stepped    = stepped

        -- iterate backward to avoid swap removal causing a cast instance to be resimulated
        for i = sp, 1, -1 do
            -- read components
            local position: Vector3 = _POSITION[i]
            local velocity: Vector3 = _VELOCITY[i]

            local velocity_step: Vector3 = velocity * dt

            local result: RaycastResult? = raycast(workspace, position, velocity_step, _RAY_PARAMS[i])
            position += velocity_step

            -- write components
            _POSITION[i] = position
            _VELOCITY[i] = velocity

            _stepped(i, dt, result)
        end

        simulating = false
    end

    -- expose functions
    cast = {
        create = create,
        getPosition = getPosition,
        setPosition = setPosition,
        getVelocity = getVelocity,
        setVelocity = setVelocity,
        addVelocity = addVelocity,
        getRaycastParams = getRaycastParams,
        setRaycastParams = setRaycastParams,
        getUserData = getUserData,
        setUserData = setUserData,
        reflect = reflect,
        terminate = terminate,
        terminateAll = terminateAll,
        getCount = getCount,
        visualize = visualize,
        bindToStepped = bindToStepped,
        simulate = simulate
    }; table.freeze(cast)
end

return cast