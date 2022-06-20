------------------------------------------------------------------------
-- Queue.lua
-- @version 1.0.0
------------------------------------------------------------------------

local _t = require(script.Parent._typedefs)

type Queue<T> = _t.Queue<T>; local Queue = {} do
    type _Queue<T> = Queue<T> & {
        head: number;
        tail: number;
        [number]: T
    }

    local QueueClass = {__metatable = "Locked"}
    QueueClass.__index = QueueClass

    function Queue.new<T>(...: T): Queue<T>
        return setmetatable({head = 1, tail = select("#", ...), ...}, QueueClass) :: any
    end

    function QueueClass.Push<T>(self: _Queue<T>, value: T)
        local tail: number = self.tail + 1
        self[tail] = value
        self.tail = tail
    end

    function QueueClass.Pop<T>(self: _Queue<T>): T?
        local head: number = self.head
        if head > self.tail then return nil end
        local value: T = self[head]
        self[head] = nil
        self.head = head + 1
        return value
    end

    function QueueClass.GetFirst<T>(self: _Queue<T>): T
        return self[self.head]
    end

    function QueueClass.GetLast<T>(self: _Queue<T>): T
        return self[self.tail]
    end

    function QueueClass.Size<T>(self: _Queue<T>): number
        return self.tail - self.head + 1
    end

    function QueueClass.__iter<T>(self: _Queue<T>)
        local head: number = self.head
        return function(state: Queue<T>, k: number): (number, T)
            local v: T = state[head + k]
            return (v and k+1) :: number, v
        end, self, 0
    end

    table.freeze(Queue)
end

return Queue
