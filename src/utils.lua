local function getfile(filename)
  local file = assert(io.open(filename, "rb"))
  return string.gmatch(file:read("*a"), "[^\n]+\n?") 
end


local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function measure(d, p, fn, args) 
    -- TODO: default args argument
    local begin = os.clock() 
    local result = fn(args)
    -- TODO: Better time formatting
    print("== Day " .. d .. " part " .. p ..": " .. result ..  " (" ..(os.clock() - begin) * 1000 .."ms)")
end

local function test(d,p, fn, args, expected) 
  local result = fn(args) 
  if result ~= expected then 
    print("$$ Day " .. d .. " part " .. p .. " example mismatch: " .. result .. " (" .. expected .. " expected)")
    return false 
  end
  return true 
end 

---@class 
AocDay = {}

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

---comment
---@param fn fun(i: {input:fun(): string|nil, state: table})
---@param args table 
---@param expected integer
---@return boolean
function AocDay:run(fn, args, expected) 
  local main_args = table.copy(args)
  main_args.input  = self.input
  main_args.state = self.state

  local test_args = table.copy(args)
  test_args.state = self.teststate 
  if args.example ~= nil then 
    print("testing with input: ", args.example)
    test_args.input = args.example
  else 
    test_args.input  = self.example
  end 

  local test_r = test(self.day, self.partn, fn, test_args, expected) 
  if test_r then 
    measure(self.day, self.partn, fn, main_args)
  end 

  self.partn = self.partn + 1
  return test_r
end 


local function create(d)
  return {
    day = d, 
    partn = 0, 
    example =  getfile("data/day" ..  d .. "/example1.txt"),
    input = getfile("data/day" .. d .. "/input1.txt"),
    state = {}, 
    teststate = {}, 
    run = AocDay.run,
  } 
  
end


return {
  dump = dump,
  create = create,
}
