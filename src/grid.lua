require("src.iter")


--- @class Grid 
--- @field data string[]
--- @field width integer
--- @field height integer 
Grid = {}


--- comment
--- @param s string
--- @return Grid
function Grid:fromString(s)
  return Grid:fromLineIter(Iter:wrap(s:gmatch("[^\n]+\n")))
end


--- comment
--- @param t any
--- @return Grid 
function Grid:fromTable(t) 
  return Grid:fromLineIter(table.ipair_iter(t))

end 

--- creates a grid from an iterator 
--- @param i Iter
--- @return Grid 
function Grid:fromLineIter(i)
  local line_width = 0 
  local height = 0 
  local data = Iter:wrap(i):map(function(x) 
    line_width = math.max(line_width, #x)
    height = height + 1
    return x 
  end ):collect()
  self.__index = self 
  return setmetatable({data = data, width = line_width, height=height}, self)
  
end

---comment
---@param self Grid
---@param x integer
---@param y integer
---@return string|nil
function Grid:get(x,y)
  if x < 1 or x > self.width or y < 1 or y > self.height then 
    return nil 
  end 
  return self.data[y]:sub(x,x)
end
---comment
---@param x integer
---@param y integer
---@param w integer
---@return string|nil
function Grid:get_line(x,y,w)
  if x < 1 or x > self.width or y < 1 or y > self.height then 
    return nil 
  end 
  if w < 1 or w + x - 1 > self.width then 
    w = - x  
  end 
  return self.data[y]:sub(x,x + w - 1)
end


---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return Grid|nil
function Grid:rect(x,y,w,h) 
  local ret = self:rect_iter(x,y,w,h) 
  if ret ~= nil then return Grid:fromLineIter(ret) end 
  return ret 
end 
    
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return Iter|nil
function Grid:rect_iter(x,y,w,h) 
  if x < 1 or x > self.width or y < 1 or y > self.height then 
    return nil 
  end 
  if w < 1 or w + x -1 > self.width or h < 1 or y + h - 1 > self.height then 
    return nil 
  end 
  local ly = y + h - 1
  return Iter:wrap(function() 
    if y > ly then return nil end 
    local l = self:get_line(x,y,w) 
    y = y + 1 
    return l 
  end)

end 
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param f string
---@return Grid
function Grid:rect_fill(x,y,w,h,f) 
  return Grid:fromLineIter(self:rect_fill_iter(x,y,w,h,f)) 
end 

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param f string
---@return Iter
function Grid:rect_fill_iter(x,y,w,h,f) 
  -- print("rect", x,y,w,h )
  local fw = w+x-1
  local fh = h+y-1
  if x < 1 then 
    local to_fill = 1-x 
    -- print("neg x", x,fw, to_fill )
    return self:rect_fill_iter(1,y,w-to_fill,h,f):map(
      function (it) return f:rep(to_fill, "") .. it  
     end)
  elseif  y < 1 then 
    local  to_fill = 1 - y  
    -- print("neg y", y,fh, to_fill )
    return Iter:rep(f:rep(w, ""),to_fill):append(self:rect_fill_iter(x,1,w,h-to_fill,f))
  elseif w < 1 then assert(false, "Negative width : " .. w ) 
  elseif h < 1 then assert(false, "Negative height: " .. h ) 
  elseif  fw > self.width then 
    local to_fill = fw - self.width 
    -- print("wide", x,fw,to_fill)
    return self:rect_fill_iter(x,y,w-to_fill,h,f):map(
      function (it) return it .. f:rep(to_fill, "")   
     end)
  elseif fh > self.height then 
    local  to_fill = fh - self.height  
    -- print("tall", y,fh, to_fill )
    return self:rect_fill_iter(x,y,w,h-to_fill,f):append(Iter:rep(f:rep(w, ""), to_fill))
  end 
  return assert(self:rect_iter(x,y,w,h))
end 

function Grid:get_lines()
  return table.ipair_iter(self.data)
end

function Grid:coords()
  return Iter:range(1,self.height):product(function(y) 
    return Iter:range(1,self.width):map(function (x)
        -- print(x,y)
        local t = {x=x, y=y} 
        -- print(t)
        return t
     end)
  end )
  
end

function Grid:chars() 
  return self:get_lines():product(function (line)
    return Iter:from_str(line) end )
end 

function Grid:kernel(w,h,f)
  local cw = math.floor(w / 2)
  local ch = math.floor(h / 2)
  return self:coords():map(function(v)
    return self:rect_fill(v.x -cw, v.y - ch, w, h,f)
  end)
end

function Grid:kernel_with_coords(w,h,f)
  local cw = math.floor(w / 2)
  local ch = math.floor(h / 2)
  return self:coords():map(function(c)
    return {g = self:rect_fill(c.x -cw, c.y - ch, w, h, f), x=c.x, y=c.y}
  end)
end

function Grid:to_string() 
  return self:get_lines():stitch_lines()
end

local function test()
  print("creating grid")
  local test1 = Grid:fromLineIter(Iter:rep("12345", 5)) 
  print("taking super grid")
  local super = test1:rect_fill(0,0,7,7,"X")
  print("printint")
  io.write(super:to_string())
  print("kernel")
  super:kernel(7,7,"Y"):map(function (k) 
    io.write(("="):rep(7,"").. "\n")
    io.write(k:to_string())
    return 1 
  end):collect() 
end


