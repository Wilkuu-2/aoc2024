local aoc = require("src.utils")
require("src.iter")
require("src.grid")

local day6 = aoc.create(6)

local function coord_eq(a, b)
    local res = a.x == b.x and a.y == b.y
    -- print(aoc.dump(a),aoc.dump(b), res)
    return res
end

local function init(args)
    local grid = Grid:fromLineIter(Iter:wrap(args.input):map(function(x)
        return (x:sub(1, #x - 1))
    end))
    local start = grid:coords():find(function(c)
        return grid:get(c.x, c.y) == "^"
    end)
    print(aoc.dump(start))
    local path = Path:create(grid, Point:new(start.x, start.y))
    args.state.path = path
    return start.x
end

---@class Point
---@field x integer 
---@field y integer 
Point = {}

Point.mt = {__add = Point.add, __index = Point}

---Creates a point 
---@param x integer
---@param y integer
---@return Point
function Point:new(x, y) return setmetatable({x = x, y = y}, Point.mt) end
function Point:from_table(t) return setmetatable({x = t.x, y = t.y}, Point.mt) end
--- Adds two points together 
---@param a Point
---@param b Point 
---@return Point
function Point.add(a, b) return Point:new(a.x + b.x, a.y + b.y) end

function Point:copy() return Point:new(self.x, self.y) end

function Point:to_string() return string.format("%d,%d", self.x, self.y) end

---@class Path
---@field grid Grid
---@field steps {table :[boolean]}
---@field start Point
---@field location Point
---@field idir  integer
Path = {}
Path.mt = {__index = Path}

function Path:create(grid, start)
    local p = {
        start = start,
        idir = 1,
        grid = grid,
        location = Point:new(start.x, start.y),
        steps = {}
    }
    return setmetatable(p, Path.mt)
end

---comment
---@param p Point
---@return [boolean]|nil
function Path:get_step(p) return self.steps[p:to_string()] end

---comment
---@param p Point
function Path:step_add(p)
    local s = self:get_step(p)
    local n = s ~= nil
    if not n then
        self.steps[p:to_string()] = {
            [1] = false,
            [2] = false,
            [3] = false,
            [4] = false
        }
        s = self:get_step(p)
    end
    s[self.idir] = true
    return n
end

function table.pair_size(t)
    local sum = 0
    for _, _ in pairs(t) do sum = sum + 1 end
    return sum
end

function table.deep_copy(t)
    local out = {}
    for key, value in pairs(t) do
        if type(value) == "table" then
            out[key] = table.deep_copy(value)
        else
            out[key] = value
        end
    end
    return out
end

function Path.copy(p)
    local z = Path:create(p.grid, p.start:copy())
    z.location = p.location:copy()
    z.idir = p.idir
    z.steps = table.deep_copy(p.steps)
    return z
end

local function count_dirs(c)
    local sum = 0
    for _, v in ipairs(c) do if v then sum = sum + 1 end end
    return sum
end

local function most_crossed(p1, p2, pt)
    local c1 = p1:get_step(pt)
    local c2 = p2:get_step(pt)

    if c2 == nil and c1 == nil then
        return p1.grid:get(pt.x, pt.y)
    elseif c1 == nil then
        return "*"
    elseif c2 ~= nil and count_dirs(p2) > count_dirs(p1) then
        return "*"
    else
        return "@"
    end
end

---comment
---@param p1 Path
---@param p2 Path
function Path.duo_print(p1, p2)
    ---@type Grid
    local grid = p1.grid
    local last_index = 1
    io.write(grid:coords():fold("", function(s, c)
        local pt = Point:new(c.x, c.y)
        local ch = most_crossed(p1, p2, pt)
        if pt.y > last_index then
            last_index = pt.y
            ch = "\n" .. ch
        end

        return s .. ch
    end) .. "\n\n")
    io.flush()
    sleep(0.01)

end

function sleep(a)
    local sec = tonumber(os.clock() + a);
    while (os.clock() < sec) do end
end

local dirs = {
    [1] = Point:new(0, -1),
    [2] = Point:new(1, 0),
    [3] = Point:new(0, 1),
    [4] = Point:new(-1, 0)
}

---comment
---@param path Path
---@param fn fun(Path)
---@param log boolean|nil
---@param add_obstacle Point|nil 
---@return nil
local function traverse(path, fn, log, add_obstacle)
    local do_log = log or false
    local obstacle = add_obstacle or Point:new(-1, -1)
    local grid = path.grid
    local nsteps = 1
    local next_loc = Point.add(path.location, dirs[path.idir])
    path:step_add(path.location)
    local g = grid:get(next_loc.x, next_loc.y)
    local n = 0

    while g ~= nil do
        -- Turn and retry when in front of the obstacle 
        if g == "#" or (next_loc.x == obstacle.x and next_loc.y == obstacle.y) then
            path.idir = 1 + ((path.idir) % 4)
            next_loc = Point.add(path.location, dirs[path.idir])
            g = grid:get(next_loc.x, next_loc.y)
            goto continue
        end

        -- count total amount of iterations
        n = n + 1

        fn(path)
        -- check if the next location adds to a loop 
        local node = path:get_step(next_loc)
        if node ~= nil and node[path.idir] then
            if do_log then
                print("Found cycle at: (" .. next_loc:to_string() .. ")")
            end
            return nil
        end

        if not path:step_add(next_loc) then nsteps = nsteps + 1 end
        path.location = next_loc
        next_loc = Point.add(next_loc, dirs[path.idir])
        g = grid:get(next_loc.x, next_loc.y)
        ::continue::
    end
    return nsteps
end

local function part1(args)
    ---@class Path 
    local path = Path.copy(args.state.path)
    -- local path = args.state.path 
    return traverse(path, function(_) end)
end

local function part2(args)
    local dupe_set = {}
    local sum = 0
    ---@class Path 
    local path = args.state.path
    local plen = traverse(path, function(npath)
        local il = Point.add(npath.location, dirs[npath.idir])
        local g = npath.grid:get(il.x, il.y)
        if g ~= nil and dupe_set[il:to_string()] == nil and npath:get_step(il) ==
            nil then
            local ret = traverse(npath:copy(), function() end, false, il)
            if ret == nil then
                -- sum = sum + 1
                dupe_set[il:to_string()] = true
            end
        end
    end, false)

    assert(plen, 4964, string.format("%d ~= %d", plen, 4964))
    return table.pair_size(dupe_set)
end

day6:run(init, {}, 5)
day6:run(part1, {}, 41)
day6:run(part2, {}, 6)
