local aoc = require("src.utils")
require("src.iter")
require("src.grid")

local day7 = aoc.create(7)

---@class Equation
---@field result  integer
---@field factors integer[]


local function init(args)
  ---@type Equation[]
  local equations = Iter:wrap(args.input):map(function(l)
    local getnum = l:gmatch("%d+")
    local result = tonumber(getnum())
    local factors = {}  
    for f in getnum do 
      factors[#factors+1] = tonumber(f)
    end 
    return {result=result, factors=factors}
  end ):collect()
  args.state.equations = equations 
  return #equations
end


local function int_concat(a,b) 
  return tonumber(""..a..b)
end


---comment
---@param eq Equation
---@return boolean
local function find_solutions(eq, muls, concats ,  s ,b, e)
  if muls == 0 then 
    local sum = s 
    for i = b,e,1 do 
      sum = sum + eq.factors[i]
    end 
    if sum == eq.result then
      return true 
    end
    muls = 1 
  end 
  
  if b > #eq.factors then 
    return s == eq.result 
  end 


  -- put in a mul somewhere 
  local m0 = find_solutions(eq, muls-1, concats , s * eq.factors[b] , b+1, e)
  local m1 = find_solutions(eq, muls  , concats , s + eq.factors[b] , b+1 ,e)
  local m2 = false 
  if concats > 0 then 
     m2 = find_solutions(eq, muls  , concats-1 , int_concat(s,eq.factors[b]), b+1 ,e)
  end 

  return m0 or m1 or m2
end 

local function part1(args)
  ---@type Equation[]
  local equations = args.state.equations 
  local acc = 0 
  for _,eq in ipairs(equations) do 
    local sols = find_solutions(eq, 0, 0, eq.factors[1], 2, #eq.factors)
    if sols then 
      acc = acc + eq.result 
    end 
  end 
  return acc 
end

local function part2(args)
  ---@type Equation[]
  local equations = args.state.equations 
  local acc = 0 
  for _,eq in ipairs(equations) do 
    local sols = find_solutions(eq, 0, #eq.factors, eq.factors[1], 2, #eq.factors)
    if sols then 
      acc = acc + eq.result 
    end 
  end 
  return acc 
end

day7:run(init, {}, 9)
day7:run(part1, {}, 3749)
day7:run(part2, {}, 11387)
