local util = require("src.utils")
Iter = {} 

function Iter:create(fn)
  local out = {fn = fn}
  self.__index = self 
  return setmetatable(out, self)
end

function Iter:collect()
  local out = {} 
  local i,x = self.fn() 
  while x ~= nil do 
    out[i] = x  
    i,x = self.fn()
  end
  return out
end 

function Iter:map(fn) 
  local map = Iter:create(function ()  
    local i,x = self.fn()
    if x ~= nil then 
     return i,fn(x) 
    end 
    return nil
  end)
  return map 
end  

function Iter:fold(init, fn) 
  for _,x in self.fn do
    init = fn(init,x)
  end
  return init
end 


function Stateless2iter(t, stateless) 
  local f = stateless 
  local i = 0; 
  local v = 0; 
  local iter = Iter:create(function()
    i,v = f(t,i) 
    return i,v
  end)
  return iter 
end  

function table.ipair_iter(t)
  return Stateless2iter(t, ipairs(t))
end 

function table.pair_iter(t)  
  return Stateless2iter(t,pairs(t)) 
end 

function Test()
  local t = {[1] = "Hello, ", [2] = "world", [3] = "!"} 
  local iter1 = table.ipair_iter(t)
  local str = iter1:fold("", function (b, x)
      return b .. x
  end)
  print(str)

  local iter2 = table.ipair_iter(t) 
  local map = iter2:map(function (x) return x .. " CLAP " end)
  local tab = map:collect()

  print(util.dump(tab))
end



Test()



