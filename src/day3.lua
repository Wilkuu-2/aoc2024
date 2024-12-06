aoc = require("src.utils")
require("src.iter")
local part2ex =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

day3 = aoc.create(3)

local function init(i)
    local tokens = {}
    for line in i.input do
        local cursor = 1
        Iter:wrap(function()
            ::reset::
            if cursor > #line then return nil end

            local c = line:sub(cursor, cursor)
            while c ~= "m" and c ~= "d" do
                if cursor > #line then return nil end
                cursor = cursor + 1
                c = line:sub(cursor, cursor)
            end
            cursor = cursor + 1
            if c == 'm' then
                local sub = line:sub(cursor - 1, #line)
                cursor = cursor + 1
                local b, e, _ = sub:find("mul%(%d+,%d+%)")
                if b == 1 then
                    cursor = cursor + e - 2
                    local s = sub:sub(b, e)
                    return s
                end
            elseif c == 'd' then
                local sub = line:sub(cursor - 1, #line)
                cursor = cursor + 1
                local b, e, _ = sub:find("do%(%)")
                if b == 1 then
                    cursor = cursor + e - 2
                    local s = sub:sub(b, e)
                    return s
                end
                b, e, _ = sub:find("don't%(%)")
                if b == 1 then
                    cursor = cursor + e - 2
                    local s = sub:sub(b, e)
                    return s
                end
            end
            goto reset
        end):list_append(tokens)
    end
    i.state.tokens = tokens
    return #tokens
end

local function part1(i)
    init(i)
    return table.ipair_iter(i.state.tokens):map(function(x)
        if x:sub(1, 3) ~= "mul" then return 0 end
        local m = x:gmatch("%d+")
        local a = tonumber(m())
        local b = tonumber(m())
        return a * b
    end):sum()
end

local function part2(i)
    local enabled = true
    return table.ipair_iter(i.state.tokens):map(function(x)
        print(x)
        local s = x:sub(1, 3)
        if s == "do(" then
            enabled = true
            return 0
        elseif s == "don" then
            enabled = false
            return 0
        elseif not enabled then
            return 0
        end

        local m = x:gmatch("%d+")
        local a = tonumber(m())
        local b = tonumber(m())
        return a * b
    end):sum()
end

day3:run(function() return 4 end, {}, 4)
day3:run(part1, {}, 161)
day3:run(part2, {example = part2ex}, 48)

