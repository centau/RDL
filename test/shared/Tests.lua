--------------------------------------------------------------------------------
-- Unit tests
--------------------------------------------------------------------------------

local rdl = require(script.Parent.RDL)
local TEST, CASE, CHECK = require(script.Parent.UnitTest)()

local function tablesAreEqual(a, b): boolean
    if #a ~= #b then return false end

    for i, v in next, a do
        if b[i] ~= v then
            return false
        end
    end

    for i, v in next, b do
        if a[i] ~= v then
            return false
        end
    end

    return true
end

local function approx(a: number, b: number, tolerance: number): boolean
    return math.abs(a - b) <= tolerance
end

do TEST "RDL::Queue"
    local Queue = rdl.Queue

    do CASE "Queue::new"
        local q = Queue.new(1, 2, 3)
        CHECK(q:Pop() == 1)
        CHECK(q:Pop() == 2)
        CHECK(q:Pop() == 3)
        CHECK(q:Pop() == nil)
    end

    do CASE "Queue::Push/Pop"
        local q = Queue.new()
        q:Push(1)
        q:Push(2)
        CHECK(q:Pop() == 1)
        CHECK(q:Pop() == 2)
        CHECK(q:Pop() == nil)
        q:Push(3)
        CHECK(q:Pop() == 3)
    end

    do CASE "Queue::Size"
        local q = Queue.new()
        for i = 1, 10 do
            q:Push(i)
        end
        CHECK(q:Size() == 10)
        for i = 1, 4 do
            q:Pop()
        end
        CHECK(q:Size() == 6)
        for i = 1, 6 do
            q:Pop()
        end
        CHECK(q:Size() == 0)
    end

    do CASE "Queue::__iter"
        local q = Queue.new(1, 2, 3, 4, 5)
        local read = {}
        for i, v in q do
            read[i] = v 
        end
        CHECK(#read == 5)
        for i, v in read do
            CHECK(q:Pop() == v)
        end
    end
end

do TEST "RDL::Complex"
    local Complex = rdl.Complex

    do CASE "Complex::new"
        local z = Complex.new(2, 4)
        CHECK(z.X == 2)
        CHECK(z.Y == 4)
    end

    do CASE "Complex::fromPolar"
        local z = Complex.fromPolar(math.rad(45), 2)
        CHECK(approx(1.41, z.X, 0.1))
        CHECK(approx(1.41, z.Y, 0.1))
    end

    do CASE "Complex::ToPolar"
        local z = Complex.new(-3, -4)
        local a, m = z:ToPolar()
        CHECK(approx(a, math.rad(-126.87), 0.1))
        CHECK(m == 5)
    end

    do CASE "Complex::__eq"
        CHECK(Complex.new(1, 1) == Complex.new(1, 1))
        CHECK(Complex.new(1, 1) ~= Complex.new(2, 1))
        CHECK(Complex.new(1, 1) ~= Complex.new(1, 2))
    end

    do CASE "Complex::__pow"
        local z = Complex.new(3, 4) :: any
        local two = Complex.new(2, 0) :: any

        local w1, w2 = z^two, z*z
        CHECK(approx(w1.X, w2.X, 0.01))
        CHECK(approx(w1.Y, w2.Y, 0.01))
    end
end

do TEST "RDL::ScriptSignal"
    local Signal = rdl.ScriptSignal :: any
    local N = 100

    do CASE "Fires all connections"
        local signal = Signal.new()

        local connections = table.create(N)
        local results = table.create(N)
        local expected = table.create(N)

        for i = 1, N do
            expected[i] = i
            connections[i] = signal:Connect(function()
                results[i] = i
            end)
        end

        signal:Fire()

        CHECK(tablesAreEqual(results, expected))
    end

    do CASE "Connections disconnected"
        local signal = Signal.new()

        local connections = table.create(N)
        local results = table.create(N)
        local expected = table.create(N)

        for i = 1, N do
            connections[i] = signal:Connect(function()
                results[i] = i
            end)
        end

        for i = 1, N, 2 do
                connections[i]:Disconnect()
        end

        signal:Fire()

        local passed = true

        for i = 1, N, 2 do
                if results[i] ~= nil then
                    passed = false
                    break
                end
        end
        for i = 2, N, 2 do
                if results[i] ~= i then
                    passed = false
                    break
                end
        end

        CHECK(passed)
    end

    do CASE "Firing with correct arguments"
        local signal = Signal.new()

        local connections = table.create(N)
        local results = table.create(N)
        local expected = table.create(N)

        for i = 1, N do
            expected[i] = i
            connections[i] = signal:Connect(function(index)
                if index == i then
                    results[i] = i
                end
            end)
        end

        for i = 1, N do
            signal:Fire(i)
        end

        CHECK(tablesAreEqual(results, expected))
    end

    -- does a connection made in an event handler fire in the same resumption cycle?
    do CASE "Recursive connecting"
        local signal = Signal.new()

        local ran = true

        signal:Connect(function()
            signal:Connect(function()
                ran = false
            end)
        end)

        signal:Fire()

        CHECK(ran)
    end

    -- does disconnecting other connections from within a connection cause unexpected behaviour?
    -- the main concern here is that the method of disconnecting can interrupt the order of firing
    -- and cause a connection to be missed or fired again.
    do CASE "Diconnecting connections within other connenctions"
        local signal = Signal.new()

        local connections = table.create(N)
        local results = table.create(N, 0)

        local random = table.create(N) -- array mapping what connections will disconnect what connections
        math.randomseed(os.clock())
        for i = 1, N do
              if math.random() > 0.5 then
                    random[i] = math.random(1, N)
              end
        end

        local toDisconnect = {} -- array of connections to be disconnected
        for _, i in next, random do
              toDisconnect[i] = true
        end

        for i = 1, N do
              connections[i] = signal:Connect(function()
                    if toDisconnect[i] == nil then -- if this connection will not be disconnected then
                          results[i] += 1
                    end

                    local connectionToDisconnect = random[i]
                    if connectionToDisconnect then
                          connections[connectionToDisconnect]:Disconnect() -- disconnect what was originally mapped to be
                    end
              end)
        end

        signal:Fire()

        local passed = true
        for i = 1, N do
              if toDisconnect[i] == nil then -- value at index should be incremented if the connection was never disconnected
                    if results[i] ~= 1 then
                          passed = false
                    end
              end
        end

        CHECK(passed)
    end

    -- similar to test 5 except there is also recursive firing
    -- does repeatedly firing while also diconnecting within the same firing cycle cause unexpected behaviour? (very edge case)
    -- basically ensures all connections that are not being disconnected are called the same amount of times
    do CASE "wth"
        local signal = Signal.new()

        local connections = table.create(N)
        local results = table.create(N, 0)

        local random = table.create(N)
        math.randomseed(os.clock())
        for i = 1, N do
              if math.random() > 0.5 then
                    random[i] = math.random(1, N)
              end
        end

        local toDisconnect = {}
        for _, i in next, random do
              toDisconnect[i] = true
        end

        local c = 0
        for i = 1, N do
              connections[i] = signal:Connect(function()
                    if toDisconnect[i] == nil then
                          c += 1
                          if c == 3 then
                                signal:Fire()
                                c+=1
                          end
                          results[i] += 1
                    end

                    local connectionToDisconnect = random[i]
                    if connectionToDisconnect then
                          connections[connectionToDisconnect]:Disconnect()
                    end
              end)
        end

        signal:Fire()

        local target = nil

        local passed = true
        for i = 1, N do
              if toDisconnect[i] == nil then
                    if target == nil and results[i] ~= 0 then
                          target = results[i]
                    end

                    if toDisconnect[i] == nil then
                          if results[i] ~= target then
                                passed = false
                          end
                    end
              end
        end

        CHECK(passed)
    end
end

TEST "END"

return nil