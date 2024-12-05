local aoc = require("src.utils")
require("src.iter")

local day5 = aoc.create(5)

local function init(i)
  local rules = {} 
  local lines = {} 
  for x in i.input do
    if  #x > 9 then 
      lines[#lines+1] = Iter:wrap(x:gmatch("%d+")):collect()     
      break
    end 
    local v = x:gmatch("%d+") 
    local b,a = v(),v()
    local r = rules[a] 
    if r == nil then
      r = {} 
      rules[a] = r
    end 
    r[#r+1] = b
  end
  for x in i.input do 
    lines[#lines+1] = Iter:wrap(x:gmatch("%d+")):collect()     
  end 
  i.state.lines = lines
  i.state.rules = rules 
  return #lines
end

local function check_rule(i,l) 
  for o,x in ipairs(l) do 
    local r0 = i.state.rules[x] 
    if r0 == nil then goto continue end 
    for _,y in ipairs(r0) do
      -- for each rule regarding x 
      for j = o,#l,1 do
        local z = l[j]
        -- check every number after x 
        if y == z then 
          return false
        end 
      end  
    end  
      ::continue::
  end 
  return true  
end 

local function reorder_manuals(i,l,v) 
  local correct = l  
  if v == #l then return l end 
  for o = v,#correct,1 do 
    :: begin_loop ::
    local x = correct[o]
    local r0 = i.state.rules[x] 
    if r0 == nil then goto continue end 
      -- for each rule regarding x 
      for j = o,#l,1 do
        local z = l[j]
        for _,y in ipairs(r0) do
        -- check every number after x 
        if y == z then 
          local a = table.remove(correct, j)
          assert(a == z)
          table.insert(correct, o, a) 
          goto begin_loop
        end 
      end  
    end  
      ::continue::
  end 
  return correct 
end 

local function part1(args)
  return table.ipair_iter(args.state.lines)
    :filter(function(l) return check_rule(args, l) end)
    :fold(0, function (s, l) return s + l[math.ceil(#l/2)] end)
  
end 

local function part2(args)
  return table.ipair_iter(args.state.lines)
    :filter(function(x) return (not check_rule(args,x)) end)
    :fold(0,function(s,x) return s + reorder_manuals(args,table.copy(x),1)[math.ceil(#x/2)] end)
end 


day5:run(init, {}, 6)
day5:run(part1, {}, 143)
day5:run(part2, {}, 123)
