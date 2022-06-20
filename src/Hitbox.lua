------------------------------------------------------------------------
-- Hitbox.lua
-- @version 0.0.0
-- @author centau_ri
------------------------------------------------------------------------

local _t = require(script.Parent._typedefs)

local ScriptSignal = require(script.Parent.ScriptSignal)

type Hitbox = _t.Hitbox; local Hitbox = {} do
    type Array<T> = {[number]: T}
    type _Hitbox = Hitbox & {
        _Attachments: Array<Attachment>;
        _Stepped: RBXScriptConnection?;
    }

    local HitboxClass = {__metatable = "Locked"}
    HitboxClass.__index = HitboxClass

    local DEBUG_FOLDER_NAME = "HitboxDebugFolder"
    local DEFAULT_NAME = "RayPoint"
    local DEFAULT_RAYCAST_PARAMS = RaycastParams.new()

    local raycast = workspace.Raycast
    local stepped: RBXScriptSignal = game:GetService("RunService").Heartbeat
    local workspace = workspace :: any

    local function trace(a: Vector3, b: Vector3)
        if workspace[DEBUG_FOLDER_NAME] == nil then
            (Instance.new :: any)("Folder", workspace).Name = DEBUG_FOLDER_NAME
        end
        local p: Part = Instance.new("Part")
        p.Name = "HitboxDebugPart"
        p.Material = Enum.Material.Neon
        p.Color = Color3.new(255, 0, 0)
        p.Size = Vector3.new(0.1, 0.1, (a-b).Magnitude)
        p.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, 0 -p.Size.Z/2)
        p.Anchored = true
        p.CanTouch = false
        p.CanCollide = false
        p.CanQuery = false
        p.Parent = workspace
    end

    function Hitbox.new(object: Instance, attachmentName: string?): Hitbox
        local self: _Hitbox = setmetatable({}, HitboxClass) :: any

        self._Attachments = {}
        self._Stepped = nil

        self.RaycastParams = DEFAULT_RAYCAST_PARAMS
        self.Debug = false
        self.Hit = ScriptSignal.new()

        attachmentName = attachmentName or DEFAULT_NAME
        for i: number, v: Instance in next, object:GetDescendants() do
            if v:IsA "Attachment" and v.Name == "attachmentName" then
                table.insert(self._Attachments, v)
            end
        end

        return self
    end

    function HitboxClass.Start(self: Hitbox)
        if self._Stepped ~= nil then error("Hitbox already active", 2) end

        local lastPositions: array<Vector3> = table.create(#self._Attachments)
        local raycastParams: RaycastParams = self.RaycastParams

        for i: number, attachment: Attachment in ipairs(self._Attachments) do
            lastPositions[i] = attachment.WorldPosition
        end

        self._Stepped = stepped:Connect(function()
            for i: number, attachment: Attachment in ipairs(self._Attachments) do
                local currentPosition: Vector3 = attachment.WorldPosition
                local lastPosition: Vector3 = lastPositions[i]
                lastPositions[i] = currentPosition

                local result: RaycastResult? = raycast(workspace, lastPosition, currentPosition - lastPosition, raycastParams)
                if result then
                    self.Hit:Fire(result :: any)
                end
                if self.Debug == true then
                    trace(lastPosition, currentPosition)
                end
                if self._Stepped == nil then break end -- if hitbox was stopped during a hit
            end
        end)
    end

    function HitboxClass:Stop()
        self._Stepped:Disconnect()
        self._Stepped = nil
    end

    function HitboxClass:__tostring(): string
        return "Hitbox"
    end

    table.freeze(Hitbox)
end

return Hitbox