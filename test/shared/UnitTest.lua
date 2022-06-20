--------------------------------------------------------------------------------
-- Test.lua
--------------------------------------------------------------------------------

type Array<T> = {[number]: T}
type Map<T, U> = {[T]: U}
type Function = () -> nil

type TestCase = {
    Name: string;
    Result: boolean;
}

local activeTestName: string?
local activeCase: TestCase?
local cases: Array<TestCase> = {}

local function displayLastTestResults()
    local pass: boolean = true
    local s: string = (activeTestName :: string) .. "\n"
    for _, case: TestCase in cases do
        s ..= string.format("    [%s] %s\n", case.Result and "PASS" or "FAIL", case.Name)
        pass = pass and case.Result
    end
    if pass == true then
        print(s)
    else
        warn(s)
    end
end

local function TEST(name: string)
    if activeTestName then
        if activeCase then
            table.insert(cases, activeCase)
            activeCase = nil
            displayLastTestResults()
            table.clear(cases)
        else
            error(string.format("%s had no test cases", activeTestName), 2)
        end
    end
    activeTestName = name
end

local function CASE(name: string)
    cases[#cases + 1] = activeCase :: TestCase
    activeCase = {
        Name = name,
        Result = true
    }
end

local function CHECK(value: any)
    local case: TestCase = activeCase :: TestCase
    if case.Result == true then
        case.Result = value and true or false
    end
end

return function()
    return TEST, CASE, CHECK
end