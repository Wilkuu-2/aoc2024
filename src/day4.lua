aoc = require("src.utils")
require("src.iter")

local day4 = aoc.create(4)

local word = "XMAS"
local exaple2 = {
    [1] = "MMMSXXMASM",
    [2] = "MSAMXMSMSA",
    [3] = "AMXSXMAAMM",
    [4] = "MSAMASMSMX",
    [5] = "XMASAMXAMM",
    [6] = "XXAMMXXAMA",
    [7] = "SMSMSASXSS",
    [8] = "SAXAMASAAA",
    [9] = "MAMMMXMMMM",
    [10] = "MXMXAXMASX"
}

local function substr_diag_match(lines, x, y, cx, cy, match_str)
    local s = ""
    local d = match_str:len()
    for i = 0, d - 1, 1 do
        local ix = x + i * cx
        local iy = y + i * cy
        if ix < 1 or iy < 1 then return 0 end
        if iy > #lines then return 0 end
        local l = lines[iy]
        if ix > #l then return 0 end
        s = s .. l:sub(ix, ix)
    end

    -- print(s)
    if s == match_str then return 1 end
    return 0
end

local function match_diagonal(lines, x, y, w)
    local c = lines[y]:sub(x, x)

    if c == nil or c ~= w:sub(1, 1) then return 0 end
    local m = 0

    m = m + substr_diag_match(lines, x, y, 1, 1, w)
    m = m + substr_diag_match(lines, x, y, 1, -1, w)
    m = m + substr_diag_match(lines, x, y, -1, 1, w)
    m = m + substr_diag_match(lines, x, y, -1, -1, w)

    m = m + substr_diag_match(lines, x, y, 0, 1, w)
    m = m + substr_diag_match(lines, x, y, 0, -1, w)
    m = m + substr_diag_match(lines, x, y, 1, 0, w)
    m = m + substr_diag_match(lines, x, y, -1, 0, w)

    return m
end

local function init(i)
    local line_width = 0
    i.state.lines = Iter:wrap(i.input):map(function(x)
        line_width = math.max(line_width, #x)
        return x
    end):collect()

    i.state.line_width = line_width

    return 1
end

local function part1(i)
    init(i)
    local res = 0
    local lines = i.state.lines
    for y = 1, #lines, 1 do
        for x = 1, i.state.line_width, 1 do
            res = res + match_diagonal(lines, x, y, word)
        end
    end
    return res
end

local function p2subtest(lines, x, y, cx, cy)
    local m = 0

    m = m + substr_diag_match(lines, x - cx, y - cy, cx, cy, "MAS")
    m = m + substr_diag_match(lines, x + cx, y + cy, -cx, -cy, "MAS")

    if m >= 1 then return 1 end
    return 0
end

local function p2test(lines, x, y)
    local c = lines[y]:sub(x, x)

    if c == nil or c ~= "A" then return false end

    local m = 0

    m = m + p2subtest(lines, x, y, 1, 1)
    m = m + p2subtest(lines, x, y, -1, 1)

    return m >= 2

end

local function part2(i)
    local res = 0
    local lines = i.state.lines
    for y = 1, #lines, 1 do
        for x = 1, i.state.line_width, 1 do
            if p2test(lines, x, y) then res = res + 1 end
        end
    end
    return res
end

day4:run(function() return 0 end, {}, 0)

local function assert_eq(a, b)
    assert(a == b,
           "Assertion failed: " .. tostring(a) .. " ~= " .. tostring(b) .. " !")
end

local test_1 = {
    [1] = "SAASAAS",
    [2] = "AAAAAAA",
    [3] = "AAMMMMA",
    [4] = "SAMXMAS",
    [5] = "AAMMMAA",
    [6] = "AAAAAAA",
    [7] = "SAASAAS"
}

local test_2 = {[1] = "MXM", [2] = "XAX", [3] = "SAS"}
assert_eq(match_diagonal(test_1, 4, 4, word), 8)
assert_eq(part1({input = table.ipair_iter(test_1), state = {}}), 8)

print("Running part 1")
day4:run(part1, {}, 18)
print("Running part 2")
assert_eq(p2test(test_2, 2, 2), true)
day4:run(part2, {example = exaple2}, 9)
