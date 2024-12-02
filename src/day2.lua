local aoc = require("src.utils")
local day = aoc.create(2)

local function collect(iterator)
    local list = {}
    local i = 1
    for x in iterator do
        list[i] = x
        i = i + 1
    end
    return list
end

local function init(args)
    args.state.levels = {}
    local i = 1
    for line in args.input do
        args.state.levels[i] = collect(line:gmatch("%d+"))
        i = i + 1
    end
    print(#args.state.levels)
    return 0
end

local function nunsafe(list)
    local previous = nil
    local unsafe = 0
    local positions = {}
    local last_difference = 0
    for i, level in ipairs(list) do
        if previous == nil then
            previous = level
            goto continue
        end
        local difference = level - previous
        if difference == 0 or difference > 3 or difference < -3 then
            unsafe = unsafe + 1
            table.insert(positions, #positions, i)
        end
        -- print(i, level, last_difference, difference)
        if last_difference ~= 0 and difference ~= 0 and
            ((difference < 0 and last_difference > 0) or
                (difference > 0 and last_difference < 0)) then
            unsafe = unsafe + 1
            table.insert(positions, #positions, i)
        end
        last_difference = difference
        previous = level
        ::continue::
    end
    return {n = unsafe, p = positions}
end
local function part1(args)
    local safe = 0
    for _, line in ipairs(args.state.levels) do
        local unsafe = nunsafe(line)
        -- print("unsafe:", unsafe.n)
        if unsafe.n <= 0 then safe = safe + 1 end
    end
    return safe
end
local function part2(args)
    local safe = 0
    for _, line in ipairs(args.state.levels) do
        -- print("n =", i)
        local unsafe = nunsafe(line)
        -- print("unsafe:", unsafe.n)
        if unsafe.n == 0 then
            safe = safe + 1
        else
            for pos = 1, #line, 1 do
                local new = table.copy(line)
                table.remove(new, pos)
                local new_unsafe = nunsafe(new)
                -- print("unsafe:", new_unsafe.n)
                if new_unsafe.n == 0 then
                    safe = safe + 1
                    break
                end
            end
        end
    end
    return safe
end

day:run(init, {}, 0)
day:run(part1, {}, 2)
day:run(part2, {}, 4)
