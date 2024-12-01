local aoc = require("src.utils")

local p1data = aoc.data(1,1)

local pl = {}
local pr = {}
local i = 1;
for line in string.gmatch(p1data.input,"%d+") do
  if (i % 2 == 0) then
    local z = i/2
    pr[z] = tonumber(line)
  else
    local z = (i+1)/2
    pl[z] = tonumber(line)
  end
  i = i + 1
end

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

print(sum)

local sum2 = 0

for l = 1,#pl,1 do
  local n = pl[l]
  local k = 0;
  for r = 1,#pr,1 do
    if pr[r] == n then
      k = k+1
    end
  end
  sum2 = sum2 + (k * n)
end

print(sum2)
