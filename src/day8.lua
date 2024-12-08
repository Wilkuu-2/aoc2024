local aoc =  require("src.utils")
require("src.grid")
require("src.iter")

---comment
---@generic T 
---@return Iter<T[]>
function Iter:pairs() 
  local list = self:collect() 
  local pairs = {}
  for x = 1,#list-1,1 do
    for y = x+1,#list,1 do 
      pairs[#pairs+1] = {[1] = list[x], [2] = list[y]}
    end 
  end
  return table.ipair_iter(pairs)
end 


function init(args)
  local grid = Grid:fromLineIter(args.input)
  args.state.grid = grid
  local antennas = {} 
  args.state.antennas = antennas

  grid:coords():map(function(c) 
    local char = grid:get(c.x,c.y)
    if char ~= "." and char ~= "\n" then 
      if antennas[char] == nil then 
        antennas[char] = {} 
      end
      local t = antennas[char]
      t[#t+1] = c
    end 
  end):run_out() 

  return table.pair_size(antennas)
end

local function test_and_add_antinode(pt,a1, a2, grid, freq, antinodes, overlap)   
  if overlap == nil or not overlap then
    if pt.x == a1.x and pt.y == a1.y then return false end 
    if pt.x == a2.x and pt.y == a2.y then return false end 
  end  
  local ch = grid:get(pt.x,pt.y)
  if ch == nil or ch == "\n" then return end

  local anp = antinodes[pt:to_string()] 
  if anp == nil then 
    -- print("antinode: ", pt:to_string(),  a1:to_string(),  a2:to_string())
    anp = {}  
    antinodes[pt:to_string()] = anp 
  end 
  anp[#anp+1] = freq

end

---comment
---@param a1 Point
---@param a2 Point
---@param grid Grid
---@param freq string
---@param antinodes {string:string[]}
local function calculate_antinode2(a1,a2,grid,freq,antinodes)
  local delta = Point.sub(a1,a2)
  --dist.x = math.abs(dist.x)
  --dist.y = math.abs(dist.y)
  
  for i = 0,math.max(grid.width,grid.height),1 do 
    local d = delta:mul(i)
    test_and_add_antinode(Point.add(a1,d), a1,a2,grid,freq,antinodes,true)
    test_and_add_antinode(Point.sub(a1,d), a1,a2,grid,freq,antinodes,true)
    test_and_add_antinode(Point.add(a2,d), a1,a2,grid,freq,antinodes,true)
    test_and_add_antinode(Point.sub(a2,d), a1,a2,grid,freq,antinodes,true)
  end  
end

---comment
---@param a1 Point
---@param a2 Point
---@param grid Grid
---@param freq string
---@param antinodes {string:string[]}
local function calculate_antinode(a1,a2,grid,freq,antinodes)
  local delta = Point.sub(a1,a2)
  --dist.x = math.abs(dist.x)
  --dist.y = math.abs(dist.y)
  
  test_and_add_antinode(Point.add(a1,delta), a1,a2,grid,freq,antinodes)
  test_and_add_antinode(Point.sub(a1,delta), a1,a2,grid,freq,antinodes)
  test_and_add_antinode(Point.add(a2,delta), a1,a2,grid,freq,antinodes)
  test_and_add_antinode(Point.sub(a2,delta), a1,a2,grid,freq,antinodes)
end

---comment
---@param args {state:{grid: Grid, antennas:[{string:Point[]}]}}
local function part1(args) 
  local antinodes = {}  
  table.pair_iter(args.state.antennas):map(function (x) 
    local freq = x[1]
    local anten = x[2]
    for i = 1,#anten-1,1 do
      for j = i+1,#anten,1 do 
        calculate_antinode(anten[j],anten[i],args.state.grid, freq ,antinodes) 
      end 
    end
  end):run_out() 
  return table.pair_size(antinodes)
end 

---comment
---@param args {state:{grid: Grid, antennas:[{string:Point[]}]}}
local function part2(args) 
  local antinodes = {}  
  table.pair_iter(args.state.antennas):map(function (x) 
    local freq = x[1]
    local anten = x[2]
    for i = 1,#anten-1,1 do
      for j = i+1,#anten,1 do 
        calculate_antinode2(anten[i],anten[j],args.state.grid, freq ,antinodes) 
      end 
    end
  end):run_out() 
  return table.pair_size(antinodes)
end 

local day8 = aoc.create(8)
day8:run(init, {}, 2)
day8:run(part1, {}, 14)
day8:run(part2, {}, 34)
