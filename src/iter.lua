local util = require("src.utils")
Iter = {} 

function Iter:create(fn)
  local out = {fn = fn}
  self.__index = self 
  return setmetatable(out, self)
end

function Iter:wrap(fn) 
  if type(fn) == 'table' and getmetatable(fn) == Iter then 
    return fn    
  end 
  local i = 0 
  local v = 0
  local function f()
    v = fn()
    i = i + 1 
    return i, v
  end
  return Iter:create(f)
end 

function Iter:list_append(t) 
  self.append_app = self:map(function(x) t[#t +1] = x return 1 end):run_out()
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

function Iter:run_out()
  local i,_ = self.fn()
  while i ~= nil do
    i,_ = self.fn()
  end
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

function Iter:filter(fn)
  local i = 0 
  local filter = Iter:create(function() 
    local _,x = self.fn()
    while x ~= nil do
      if(fn(x)) then
        i = i + 1 
        return i,x 
      end 
    end 
    return nil 
  end)
  return filter 
end 

function Iter:fold(init, fn) 
  for _,x in self.fn do
    init = fn(init,x)
  end
  return init
end 


function Iter:sum() 
  return self:fold(0,function (i, x)  return i + x end)
end

function Iter:concat()
  return self:fold("",function (i, x)  return i .. x end)
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

