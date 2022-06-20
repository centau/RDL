------------------------------------------------------------------------
-- quick.lua
-- @version 0.0.0
------------------------------------------------------------------------

--[[
    GUIState data structure = {
        [number|string]: {          -- index
            [1]: any,               -- value
            [2]: {                  -- bound property data array
                [number]: {         -- bound property data
                    [1]: Instance,
                    [2]: string,    -- property name
                    [3]: Function
                }
            }
        }
    }
]]

local _t = require(script.Parent._typedefs)

local quick = {} do
    type Function = (...any) -> ...any
    type Map<T, U> = {[T]: U}

    type BoundPropertyData = {
        Instance|
        string|
        Function
    }

    type UIStateValue = {
        any|
        Array<BoundPropertyData>
    }

    type UIState = {
        [userdata]: Map<number|string, UIStateValue>
    }

    type StateReadData = {
        UIState|
        string
    }

    local STATE_INSTANCE = 1
    local STATE_FIELD    = 2

    -- toggle for listening to state binds
    local bindingNewProperty: boolean = false
    -- temporary store of states fields which were read from during component construction
    local stateFieldsRead: Array<StateReadData> = {}

    local UIState = {} do
        local UIStateClass = {__metatable = "Locked"}

        local STATE = newproxy(false) :: userdata

        local VALUE = 1
        local BOUND = 2

        local INSTANCE = 1
        local PROPERTY = 2
        local FUNCTION = 3

        function initStateValue(state: UIState, index: number|string): UIStateValue
            local t: table = { [VALUE] = nil, [BOUND] = {} }
            state[STATE][index] = t
            return t
        end

        function UIState.new(t: table): UIState
            local state: UIState = setmetatable({[STATE] = {}}, UIStateClass) :: UIState
            for i: string|number, v: any in next, t do
                (state :: table)[i] = v
            end
            return state
        end

        function UIStateClass.__index(self: UIState, index: number|string)
            if bindingNewProperty == true then
                table.insert(stateFieldsRead, {self, index})
            end

            local propertyData: UIStateValue = self[STATE][index] :: any or initStateValue(self, index)

            return propertyData[VALUE]
        end

        function UIStateClass.__newindex(self: UIState, index: number|string, value: any)
            local propertyData: UIStateValue = self[STATE][index] :: any or initStateValue(self :: UIState, index)

            propertyData[VALUE] = value

            -- update all connected properties
            for _, v: BoundPropertyData in next, propertyData[BOUND] do
                v[INSTANCE][ v[PROPERTY] ] = v[FUNCTION]()
            end
        end

        -- bind an instance to a property
        function UIStateClass:__call(index: string, instance: Instance, property: string, fn: Function)
            table.insert(self[STATE][index][BOUND], {
                [INSTANCE] = instance,
                [PROPERTY] = property,
                [FUNCTION] = fn
            })
        end

        function UIStateClass:__iter()
            --
        end

        table.freeze(UIState)
    end

    -- in charge of constructing a component given base component and table of properties
    function quick.new(name: string): (properties: Map<string, any>) -> Instance
        local instance: Instance = Instance.new(name)

        return function(properties: Map<string, any>): Instance
            for property: string, value: any in properties do
                if property == "Children" then
                    for i: number, child: Instance in next, value :: Array<Instance> do
                        if type(child) == "userdata" then
                            child.Parent = instance
                        else
                            error("Attempt to set non instance as child", 2)
                        end
                    end
                elseif typeof(instance[property]) == "RBXScriptSignal" then
                    if type(value) ~= "function" then error("Attempt to connect non-function to event", 2) end
                    instance[property]:Connect(value :: Function)
                elseif type(value) == "function" then
                    bindingNewProperty = true
                    -- set initial value and listen for dependent states
                    instance[property] = (value :: Function)()
                    for _, v: StateReadData in next, stateFieldsRead do
                        (v[STATE_INSTANCE]:: Function)(v[STATE_FIELD], instance, property, value)
                    end
                    bindingNewProperty = false
                    table.clear(stateFieldsRead)
                else
                    instance[property] = value
                end
            end

            return instance
        end
    end

    function quick.assetid(id: number): string
        return "rbxassetid://"..id
    end

    function quick.state(t): _t.UIState
        return UIState.new(t) :: _t.UIState
    end

    table.freeze(quick)
end

game:GetService("RunService")

return quick