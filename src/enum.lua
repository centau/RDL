------------------------------------------------------------------------
-- enum.lua
-- @version 1.0.0
--!strict
------------------------------------------------------------------------

--[[
    Modifies tables passed to be read-only and raise errors when nil is indexed.
]]

type Enum = {[string]: number|Enum}

local emt = table.freeze {
    __index = function(_, idx: string)
        error(string.format("%s is not a valid enum", tostring(idx)), 2)
    end
}

function enum(t: Enum): Enum
    for i: string, v: number|Enum in next, t do
        if type(i) ~= "string" then error("Enum indexes must be strings", 2) end
        if type(v) == "table" then
            t[i] = enum(v)
        end
    end
    return table.freeze( setmetatable(t, emt) ) :: any
end

return enum
