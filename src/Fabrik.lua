------------------------------------------------------------------------
-- Fabrik.lua
-- @version 0.0.0
-- @author centau_ri
------------------------------------------------------------------------

--[[
    Forward and Backward Reaching Inverse Kinematics

    X----------X----------X
    ^p1  ^l1   ^p2   ^l2  ^p_virtual
    ^root             ^end_effector
]]

local _t = require(script.Parent._typedefs)

type Fabrik = _t.Fabrik; local Fabrik = {} do
    type Array<T> = {[number]: T}
    type IKConstraint = _t.IKConstraint

    local FabrikClass = {__metatable = "Locked"}
    FabrikClass.__index = FabrikClass

    local TOLERANCE = 0.01
    local MAX_ITER = 10

    local UP    = 2
    local RIGHT = 4
    local DOWN  = 3
    local LEFT  = 1

    function Fabrik.new(): Fabrik
        local self = setmetatable({}, FabrikClass)

        self.JointPositions = table.create(1, Vector3.zero)
        self.SegmentLengths = {}
        self.JointConstraints = {}

        return self
    end

    --[[
    local tmp = Instance.new("Part")
    tmp.Parent = workspace
    tmp.Material = Enum.Material.Neon
    tmp.Color = Color3.new(1, 0, 0)
    tmp.Size = Vector3.new(1, 1, 1)
    tmp.Anchored = true
    tmp.Transparency = 0.5

    local red = tmp:Clone() red.Parent = workspace
    local blue = tmp:Clone() blue.Parent = workspace blue.Color = Color3.new(0, 0, 1)
    ]]

    local function constrain(parentCF: CFrame, childPos: Vector3, parentLength: number, constraints: IKConstraint): Vector3
        -- calculate parent cframe
        -- get child position relative to parent position
        -- aka convert child position to local space with parent position as origin
        local childPositionRelativeToParent: Vector3 = parentCF:PointToObjectSpace(childPos)
        -- get components "relative x, y, z"
        local rx: number = childPositionRelativeToParent.X
        local ry: number = childPositionRelativeToParent.Y
        local rz: number = childPositionRelativeToParent.Z

        local c = constraints
        if c == nil then return childPos end

        local sign_z: number = math.sign(rz) -- save sign of z
        rz = math.abs(rz) -- interpret positive as "in front" for ease of calculations

        -- hypotenuse, length of segment
        local h: number = parentLength

        -- find angles between z and x, z and y
        local ax: number = math.atan(rx/rz)
        local ay: number = math.atan(ry/rz)

        --local ax: number = math.asin(rx/h)
        --local ay: number = math.asin(ry/h)

        --[[
            negative values for rz return values between (+-90 and 0):
            in the case that rz is negative, angles are converted
            to a range between 0 and 180 for ease of clamping
            (angles greater than 90 means that rz is behind the parent position)
        ]]
        if sign_z == 1 then -- if z is behind parent
            if rx > 0 then
                ax = math.pi - ax
            else
                ax = -1*math.pi - ax
            end
            if ry > 0 then
                ay = math.pi - ay
            else
                ay = -1*math.pi - ay
            end
        end

        -- constrain angles
        local ax2: number = math.clamp(ax, -c[LEFT], c[RIGHT])
        local ay2: number = math.clamp(ay, -c[DOWN], c[UP])

        --print(math.deg(ay), math.deg(-c[DOWN]), math.deg(c[UP]))

        -- calculate new vector components based on clamped angles
        local rx2: number = h * math.sin(ax2)
        local ry2: number = h * math.sin(ay2)
        -- determine if z component is now in front or behind by checking if either ax2 or ay2 are greater than 90 degrees
        local s: number = ((math.abs(ax2) > math.pi/2 or math.abs(ay2) > math.pi/2) and 1 or -1)
        -- calculate new z component based on new x and y components
        local tmp: number = math.sqrt(rx2^2 + ry2^2)/h
        if tmp > 1 then warn("x"); tmp = 1 end
        local rz2: number = h * math.cos( math.asin(tmp) ) * s

    
        -- convert new constrained relative vector back to world vector
        local new: Vector3 = parentCF:PointToWorldSpace( Vector3.new(rx2, ry2, rz2) )
        --blue.Position = childPos
        --red.Position = new
        return new
    end

    function FabrikClass:BackwardSolve(target: Vector3)
        local positions: Array<Vector3> = self.JointPositions
        local lengths: Array<number> = self.SegmentLengths
        local n = #positions

        positions[n] = target

        for PARENT = n-1, 1, -1 do
            local CHILD = PARENT+1
            local parentDirectionRelativeToChild: Vector3 = (positions[PARENT] - positions[CHILD]).Unit
            positions[PARENT] = positions[CHILD] + parentDirectionRelativeToChild * lengths[PARENT]
        end
    end

    function FabrikClass:ForwardSolve(origin: Vector3)
        local positions: Array<Vector3> = self.JointPositions
        local n = #positions

        local lengths: Array<number> = self.SegmentLengths

        positions[1] = origin

        for PARENT = 1, n-1, 1 do
            local CHILD = PARENT+1
            local childDirectionRelativeToParent = (positions[CHILD] - positions[PARENT]).Unit -- Unit
            positions[CHILD] = positions[PARENT] + childDirectionRelativeToParent * lengths[PARENT]
        end
    end

    function FabrikClass:ForwardConstrainedSolve(originCF: CFrame)
        local positions: Array<Vector3> = self.JointPositions
        local n = #positions

        local lengths: Array<number> = self.SegmentLengths
        local constraints: Array<IKConstraint> = self.JointConstraints

        positions[1] = originCF.Position

        print(positions[2])
        positions[2] = constrain(originCF, positions[2], lengths[1], constraints[1])
        print(positions[2])

        for PARENT = 1, n-1, 1 do
            local CHILD = PARENT+1
            local childDirectionRelativeToParent = (positions[CHILD] - positions[PARENT]).Unit -- Unit
            positions[CHILD] = positions[PARENT] + childDirectionRelativeToParent * lengths[PARENT]
            if PARENT ~= 1 then
                local up = Vector3.new(0, 1, 0)
                --if PARENT == 2 then
                    local p1 = positions[PARENT-1]
                    local p2 = positions[PARENT]
                    local relative = p2 - p1
                    --print(relative)
                up = Vector3.new(0, 1, 0) * ((relative.Z > 0) and -1 or 1)
                --end
                local parentCF: CFrame = CFrame.lookAt(positions[PARENT-1], positions[PARENT], up) * CFrame.new(0, 0, -lengths[PARENT-1])
                local v: Vector3 = constrain(parentCF, positions[CHILD], lengths[PARENT], constraints[PARENT])
                positions[CHILD] = v
            end
        end
    end

    function FabrikClass:AddSegment(length: number, constraint: IKConstraint?): Fabrik
        local n: number = #self.JointPositions -- n includes the virtual position
        self.JointPositions[n+1] = self.JointPositions[n]
        self.SegmentLengths[n] = length
        self.JointConstraints[n] = constraint
        return self
    end

    function FabrikClass:Solve(origin: Vector3, target: Vector3)
        local positions: Array<Vector3> = self.JointPositions
        local n: number = #positions

        local lastEndEffectorPosition: Vector3 = positions[n]

        for i = 1, MAX_ITER do
            self:BackwardSolve(target)
            self:ForwardSolve(origin)
            local currentEndEffectorPosition = positions[n]

            if (currentEndEffectorPosition - lastEndEffectorPosition).Magnitude < TOLERANCE then
                return -- no change from previous solve
            elseif (currentEndEffectorPosition - target).Magnitude < TOLERANCE then
                return -- solved for target within tolerance
            end

            lastEndEffectorPosition = currentEndEffectorPosition
        end

        warn("Aborting IK solve, could not solve for target within maximum allowed iterations")
    end

    function FabrikClass:ConstrainedSolve(originCF: CFrame, target: Vector3)
        local positions: Array<Vector3> = self.JointPositions
        local n: number = #positions

        local lastEndEffectorPosition: Vector3 = positions[n]

        for i = 1, MAX_ITER do
            self:BackwardSolve(target)
            self:ForwardConstrainedSolve(originCF)
            local currentEndEffectorPosition = positions[n]

            if (currentEndEffectorPosition - lastEndEffectorPosition).Magnitude < TOLERANCE then
                return -- no change from previous solve
            elseif (currentEndEffectorPosition - target).Magnitude < TOLERANCE then
                return -- solved for target within tolerance
            end

            lastEndEffectorPosition = currentEndEffectorPosition
        end

        warn("Aborting IK solve, could not solve for target within maximum allowed iterations")
    end

    function FabrikClass:Reset()
        self.JointPositions = table.create(#self.JointPositions, Vector3.zero)
    end

    function FabrikClass:GetJointPositions(): Array<Vector3>
        return { unpack(self.JointPositions) }
    end

    function FabrikClass:GetJointCFrames(): Array<CFrame>
        local positions: Array<Vector3> = self.JointPositions
        local n: number = #positions

        local cfs: Array<CFrame> = table.create(n)

        for PARENT = 1, n-1 do
            local CHILD = PARENT+1
            cfs[PARENT] = CFrame.lookAt(positions[PARENT], positions[CHILD])
        end

        return cfs
    end

    function FabrikClass:GetJointRelativeCFrames(): Array<CFrame>
        local positions: Array<Vector3> = self.JointPositions
        local n: number = #positions

        local jointCFrames: Array<CFrame> = self:GetJointCFrames()
        local jointRelativeCFrames: Array<CFrame> = table.create(n)

        jointRelativeCFrames[1] = jointCFrames[1]

        for i = 2, n do
            jointRelativeCFrames[i] = jointCFrames[i-1]:ToObjectSpace(jointCFrames[i])
        end

        return jointRelativeCFrames
    end

    function FabrikClass:GetSegmentCFrames(): Array<CFrame>
        local positions: Array<Vector3> = self.JointPositions
        local n: number = #positions

        local lengths: Array<number> = self.SegmentLengths
        local cfs: Array<CFrame> = table.create(n)

        for PARENT = 1, n-1 do
            local CHILD = PARENT+1
            cfs[PARENT] = CFrame.lookAt(positions[PARENT], positions[CHILD]) * CFrame.new(0, 0, -0.5 * lengths[PARENT])
        end

        return cfs
    end

    table.freeze(Fabrik)
end

return Fabrik