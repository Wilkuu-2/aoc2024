local aoc = require("src.utils")
-- if unpack == nil then 
--   unpack = table.unpack
-- end  

local p1data = aoc.create(1)


local function init (args)
  local i = 1;
  -- Part 2 depends on the final state of part 1
  args.state.pl = {} 
  args.state.pr = {}
  for line in args.input do
    -- io.write(line)
    local ns = line:gmatch("%d+")
    -- Bisect is slower than sorting afterwards on lua for some reason 
    -- Sort is probably optimized well in C 
    -- bisect_insert(pl,tonumber(ns()))
    -- bisect_insert(pr,tonumber(ns()))
    
    args.state.pl[i] = tonumber(ns())
    args.state.pr[i] = tonumber(ns())
    i = i + 1
  end
  return 0
end

local function part1(args)
  local pl = args.state.pl
  local pr = args.state.pr
  table.sort(pl);
  table.sort(pr);

  local sum = 0
  local function dist (a, b)
    if a < b then
       return b - a
    else
       return a - b
    end
  end

  for p = 1,#pl,1 do
    sum = sum + dist(pl[p],pr[p])
  end
  return sum 
end

local function freq(t)
  local fr = {}
  local l = 0
  for _,x in ipairs(t) do
    local f = fr[x]
    -- print(x,f)
    if f == nil then 
      fr[x] = 1
      l = l+1
    else  
      fr[x] = f + 1
    end 
  end
  -- print(aoc.dump(fr))
  return fr 
end

local function part2 (args)
  local pr = args.state.pr
  local pl = args.state.pl
  local sum2 = 0
  local fr = freq(pr)
  for _,n in pairs(pl) do
    local f = fr[n] 
    if f == nil then 
      f = 0
    end 
    sum2 = sum2 + (n * f)
  end
    return sum2
end

p1data:run(init, {}, 0)
p1data:run(part1, {}, 11)
p1data:run(part2, {example = "" }, 31)
