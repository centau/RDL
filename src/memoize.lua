------------------------------------------------------------------------
-- memoize.lua
-- @version 1.0.0
------------------------------------------------------------------------

type Map<T, U> = {[T]: U}

local weak = {__mode = "kv"}

return function<T, U>(f: (T) -> U): (T) -> U
    local cache: Map<T, U> = setmetatable({}, weak) :: any

    return function(x: T): U
        local y: U? = cache[x]
        if y == nil then
            y = f(x)
            cache[x] = y :: U
        end
        return y :: U
    end
end