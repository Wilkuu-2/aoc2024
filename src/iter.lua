local util = require("src.utils")

--- @class Iter 
--- @field fn fun(): (integer,any) 
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

function Iter:rep(v,n) 
  assert(v, "v is nil")
  assert(type(assert(n, "n is null")) == 'number', "n is not integer")
  local i = 0 
  local function f()
    i = i + 1 
    if i > n then return i,nil end 
    return i,v 
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
      local b = fn(x)
      if(b) then
        i = i + 1 
        return i,x 
      end 
      _,x = self.fn()
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
function Iter:stitch_lines()
  return self:fold("",function (i, x)  return i .. x .. "\n" end)
end 

---@param it Iter 
---@return Iter
function Iter:append(it) 
  local i = 0 
  local i1 = 0 
  local i2 = 0 
  local first = true
  local v = 0
  local function f()
    if first then 
      i1,v = self:fn()
      if v ~= nil then 
        i = i1
        return i,v 
      end  
      first = false
    end 
    i2,v = it:fn()
  
    if i2 == nil then 
      return nil,nil
    end 

    return i+i2, v
  end
  return Iter:create(f)
end 

--- comment
--- @param fn fun(any): Iter
function Iter:product(fn) 
  local i = 0 
  local _,v0 = self.fn()
  ---@type Iter|nil
  local f1 = fn(v0) 
  
  if f1 == nil then return nil end

  local _,v1 = f1.fn()
  local function f() 
    if v1 == nil then
      _,v0 = self.fn() 
      if v0 == nil then return nil end 
      f1 = fn(v0)
      _,v1 = f1.fn()
    end 
    local v2 = v1 
    _,v1 = f1.fn()
    return i,v2
  end 

  return Iter:create(f)
end 

function Iter:from_str(s) 
  local l = s:len()
  local i = 0 
  local function f()
    i = i + 1
    if i > l then return nil end 
    return i,s:sub(i,i)
  end
  return Iter:create(f)
end

function Iter:range_inc(b,e,i)
  local x = b - 1
  local xi = 0 
  local function f() 
    x = x + i
    xi = xi + 1
    if x > e  then return nil end  
    return xi,x
  end

  return Iter:create(f)
end

function Iter:range(b,e) 
  return Iter:range_inc(b,e,1)
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

