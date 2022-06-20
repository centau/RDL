------------------------------------------------------------------------
-- .lua
-- @version v0.0.0
-- @author centau_ri
------------------------------------------------------------------------

--[[
    nodes

    composites:
        sequence
        select
        random

    decorators:
        repeat
        invert
        succeed

    actions
            

]]

local _t = require(script.Parent._typedefs)

type BehaviourTree = {

}

type Status = true|false|nil

type Node = (table) -> boolean?

type Action = (table) -> Status

local bt = {} do
    type BehaviourTree = _t.BehaviourTree

    local PARENT = 1
    local CHILDREN = 2
    local TYPE = 3

    local Status = {
        Success = true,
        Failure = false,
        Running = nil
    } table.freeze(Status)

    local NodeType = {
        Sequence = 0x01,
        Selector = 0x02
    }

    local Sequence = {} do
        local SequenceClass = {__metatable = "Locked"}
        SequenceClass.__index = SequenceClass

        function Sequence.new(children: Array<Node>): Node
            local self = setmetatable({}, SequenceClass)
            
            self.Children = children
            return self :: Node
        end

        function SequenceClass:__call(state: table)
            for i: number, v: Node in next, self.Children do
                if v(state) == false then
                    return false
                end
            end
      
            return true
        end
    end

    local Selector = {} do
        local SelectorClass = {__metatable = "Locked"}
        SelectorClass.__index = SelectorClass

        function Selector.new()
            
        end

        function SelectorClass:__call(state: table)
            for _, v: Node in next, self.Children do
                if v(state) == true then
                    return v(state)
                end
            end

            return false
        end
    end

    ---------------------------
    --[[
    ai

    if in game
        if a player exists
        if player has character
        if player is within range
            print hi
        elsa
            print not in range

    if not in game
        print not in game

    ]]

    local Players = game.Players
    local RunService = game:GetService("RunService")

    local tree: BehaviourTree = Selector.new {
        Sequence.new { -- find player and say hi
            function() -- is in game?
                if RunService:IsStudio() == false then
                    return Status.Success
                end
            end,

            Selector.new {
                Sequence.new {
                    function(s)
                        local player = Players:FindFirstChild("centau_ri")
                        if player and player.Character then
                            s.Character = player.Character
                            return Status.Success
                        else
                            return Status.Failure
                        end
                    end,

                    function(s)
                        if (s.Character.PrimaryPart.Position - s.Position).Magnitude < 10 then
                            return Status.Success
                        else
                            return Status.Failure
                        end
                    end,

                    function()
                        print("hi")
                    end
                },

                function()
                    warn "Not in range"
                    return Status.Success
                end
            }
        },

        function()
            print("Not in game")
        end
    }
end

return bt



