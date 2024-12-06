local util = require("src.utils")

--- @generic T
--- @class Iter<T>  
--- @field fn fun(): integer|nil,unknown|nil
Iter = {}

--- Creates an iterator from a function that returns index and T or nil  
---@generic T
---@param fn fun(): (integer|nil, T|nil)
---@return Iter<T>
function Iter:create(fn)
    local out = {fn = fn}
    self.__index = self
    return setmetatable(out, self)
end

--- Creates an iterator from a function that returns T or nil  
---@generic T
---@param fn fun(): (T)
---@return Iter<T>
function Iter:wrap(fn)
    if type(fn) == 'table' and getmetatable(fn) == Iter then return fn end
    local i = 0
    local v = 0
    local function f()
        v = fn()
        i = i + 1
        return i, v
    end
    return Iter:create(f)
end

---Creates a iterator that returns element `v` `n` times 
---@generic T 
---@param v T 
---@param n integer
---@return Iter<T>
function Iter:rep(v, n)
    assert(v, "v is nil")
    assert(type(assert(n, "n is null")) == 'number', "n is not integer")
    local i = 0
    local function f()
        i = i + 1
        if i > n then return i, nil end
        return i, v
    end
    return Iter:create(f)
end

---Returns all the elements in the iterator
---@generic T 
---@return T[]
function Iter:collect()
    local out = {}
    local i, x = self.fn()
    while x ~= nil and i ~= nil do
        out[i] = x
        i, x = self.fn()
    end
    return out
end

--- Drains all the iterator, discarding the value 
---@generic T 
function Iter:run_out()
    local i, _ = self.fn()
    while i ~= nil do i, _ = self.fn() end
end

---Appends a array with elements from the iterator   
---@generic T 
---@param t T[] 
function Iter:list_append(t)
    ---@diagnostic disable-next-line: undefined-field
    self.append_app = self:map(function(x)
        t[#t + 1] = x
        return 1
    end):run_out()
end

--- Returns a iterator that executes `fn` on each of the elements of the original Iter
---@generic T 
---@generic M  
---@param fn fun(T): M| nil  
---@return Iter<M>
function Iter:map(fn)
    local map = Iter:create(function()
        local i, x = self.fn()
        if x ~= nil and i ~= nil then return i, fn(x) end
        return nil
    end)
    return map
end

--- Returns an iterator of elements x from the original iterator for which fn(x) is true
---@generic T 
---@param fn fun(T): boolean   
---@return Iter<T>
function Iter:filter(fn)
    local i = 0
    local filter = Iter:create(function()
        local _, x = self.fn()
        while x ~= nil do
            local b = fn(x)
            if (b) then
                i = i + 1
                return i, x
            end
            _, x = self.fn()
        end
        return nil
    end)
    return filter
end

--- Returns the first element x in the original iterator for which fn(x) is true
---@generic T 
---@param fn fun(T): boolean   
---@return T|nil
function Iter:find(fn)
    local _, x = self.fn()
    while x ~= nil do
        local b = fn(x)
        if (b) then return x end
        _, x = self.fn()
    end

end

--- Returns an value based on the following formula Fold(i + 1) = fn(Fold(i), Iter(i)) where Fold(0) = init 
---@generic T 
---@generic R 
---@param init R 
---@param fn fun(R,T): R
---@return R
function Iter:fold(init, fn)
    for _, x in self.fn do init = fn(init, x) end
    return init
end

--- Returns the sum of the iterator, requires the iterator to be Iter<number>
---@return number
function Iter:sum() return self:fold(0, function(i, x) return i + x end) end

--- Returns the concatenation of all strings in the iterator, requires the iterator to be Iter<string>
---@return string
function Iter:concat() return self:fold("", function(i, x) return i .. x end) end
function Iter:stitch_lines()
    return self:fold("", function(i, x) return i .. x .. "\n" end)
end

---Appends one iterator to another 
---@generic T 
---@param it Iter<T> 
---@return Iter<T>
function Iter:append(it)
    ---@type integer|nil
    local i = 0
    ---@type integer|nil
    local i1 = 0
    ---@type integer|nil
    local i2 = 0
    local first = true
    ---@generic T  
    ---@type T|nil 
    local v = 0
    local function f()
        if first then
            i1, v = self:fn()
            if v ~= nil then
                i = i1
                return i, v
            end
            first = false
        end
        i2, v = it.fn()

        if i2 == nil then return nil, nil end

        return i + i2, v
    end
    return Iter:create(f)
end

--- comment
--- @generic T 
--- @generic P 
--- @param fn fun(T): Iter<P>
function Iter:product(fn)
    local i = 0
    local _, v0 = self.fn()
    ---@type Iter|nil
    local f1 = fn(v0)

    if f1 == nil then return nil end

    local _, v1 = f1.fn()
    local function f()
        if v1 == nil then
            _, v0 = self.fn()
            if v0 == nil then return nil end
            f1 = fn(v0)
            _, v1 = f1.fn()
        end
        local v2 = v1
        _, v1 = f1.fn()
        return i, v2
    end

    return Iter:create(f)
end

--- Creates an iterator of each character in a string 
---@param s string
---@return Iter<string>
function Iter:from_str(s)
    local l = s:len()
    local i = 0
    local function f()
        i = i + 1
        if i > l then return nil end
        return i, s:sub(i, i)
    end
    return Iter:create(f)
end

--- Creates an iterator of a integer range 
---@param b integer begin 
---@param e integer end 
---@param i integer increment 
---@return Iter<integer>
---@overload fun(integer, integer): Iter<integer>
function Iter:range(b, e, i)
    local ii = i or 1
    local x = b - 1
    local xi = 0
    local function f()
        x = x + ii
        xi = xi + 1
        if x > e then return nil end
        return xi, x
    end

    return Iter:create(f)
end

--- Creates a iterator from an array
--- @generic T 
--- @param t T[] 
--- @return Iter<T>
function table.ipair_iter(t)
    local f = ipairs(t)
    local i = 0;
    local v = 0;
    local iter = Iter:create(function()
        i, v = f(t, i)
        return i, v
    end)
    return iter
end

--- Creates a iterator from an associative table 
--- @generic K 
--- @generic T 
--- @param t {[K]:T}
--- @return Iter<[K,T]>
function table.pair_iter(t)
    local i = 0;
    local v = 0;
    local k = nil;
    local iter = Iter:create(function()
        k, v = next(t, k)
        i = i + 1
        if v == nil then return nil end
        return i, {v, k}
    end)
    return iter
end

function Test()
    local t = {[1] = "Hello, ", [2] = "world", [3] = "!"}
    local iter1 = table.ipair_iter(t)
    local str = iter1:fold("", function(b, x) return b .. x end)
    print(str)

    local iter2 = table.ipair_iter(t)
    local map = iter2:map(function(x) return x .. " CLAP " end)
    local tab = map:collect()

    print(util.dump(tab))
end

