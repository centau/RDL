
local shared = game:GetService("ReplicatedStorage")
require(shared.Tests)

local rdl = require(shared.RDL)

local function double(x: number): number
	return x*2
end

local f = rdl.memoize(double)

local s: string = f(2)

print(s)

----------
