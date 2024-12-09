local aoc = require("src.utils")
require("src.iter") 

---@class MemorySection
---@field free boolean 
---@field size integer 
---@field id integer


local function init(args) 
  local cursor = 1
  local i = 0
  local lastid = 0
  local line = Iter:wrap(args.input):concat()  
  local blocks = Iter:from_str(line):map(function (x) 
    local n = tonumber(x)
    --- Breaks the iterator when encountering a newline or other non-digit
    if n == nil then return nil end 
    local free = i % 2 ~= 0
    i = i + 1 
    local id = -1 
    if not free then 
      id = lastid
      lastid = lastid + 1  
    end 
    ---@type MemorySection 
    local block = {free=free,size=n,id=id} 
    cursor = cursor + n 
    return block
  end):collect()
  args.state.sections = blocks 
  args.state.last_id  = lastid -1
  -- print(aoc.dump(blocks))
  return lastid -1
end 


---comment
---@param inp MemorySection
---@param chunk MemorySection
---@returns MemorySection,MemorySection|nil
local function insert_chunk(inp, chunk) 
  if inp.size > chunk.size then
    return chunk,{free=true, size=inp.size-chunk.size, id=-1} 
  elseif inp.size < chunk.size then
    return {free=false, size=inp.size, id=chunk.id}, {free=false, size=chunk.size-inp.size, id=chunk.id}
  else 
    return {free=false,size=chunk.size,id=chunk.id}, nil
  end 
end 


---comment
---@param sections MemorySection[]
---@param id integer
---@return MemorySection|nil
local function get_file(sections, id)
  for i = 1,#sections,1 do
    local s = assert(sections[i])
    if s.id == id then 
      return s 
    end 
  end 
end

local function find_file(sections, max_size, moved) 
  for i = 0,#sections-1,1 do
    local s = assert(sections[#sections-i])
    if not s.free and s.size <= max_size and moved[s.id] == nil then 
      return s 
    end  
  end
end

local function memory_map_dump(mm) 
  local s = "" 
  for _,x in ipairs(mm) do
    if x.free then 
    s=s .. " " .. ("."):rep(x.size," ")
    else  
    s = s ..  (" " .. x.id):rep(x.size,"")
    end 
  end 
  return s
end

local function checksum(mm)
  local sum = 0 
  local i = 0 
  for _,section in ipairs(mm) do 
    for j=1,section.size,1 do  
      sum = sum + (i*section.id) 
      i = i + 1     
    end 
  end 
  return sum 
end

local function part1(args) 
  local memory_map = {} 
  local fragment_cursor = args.state.last_id
  local fill_cursor = 0
  local leftover = nil 
  for _,section in ipairs(args.state.sections) do 
    -- print("===", fragment_cursor, fill_cursor, aoc.dump(section) ,aoc.dump(leftover))
    if section.free then 
      -- print(">> Filling free sector")
      local free = section  
      while free ~= nil do
        if leftover ~= nil and leftover.id <= fill_cursor then goto continue end
        if leftover == nil then
          leftover = get_file(args.state.sections,fragment_cursor)
          -- print(aoc.dump(free), aoc.dump(leftover))
          --- breaks when no files left
          if leftover == nil or leftover.id <= fill_cursor then break end
          fragment_cursor = fragment_cursor - 1
        end 
        local insert,overflow = insert_chunk(free,leftover) 
        -- print("> " .. aoc.dump(leftover) .. " " .. aoc.dump(overflow))
        memory_map[#memory_map+1] = insert 
        if overflow == nil then
          free = nil
          leftover = nil 
        elseif overflow.free then 
          -- print("> Free space left")
          free = overflow 
          leftover = nil 
        else 
          -- print("> Taking next chunk")
          leftover = overflow
          free = nil 
        end 
      end
    else 
      -- assert(section.id ~= 5278)
      if section.id > fragment_cursor then goto continue end
      -- print(">> Placing file")
      -- print("> " .. section.id)
      fill_cursor = section.id  
      memory_map[#memory_map+1] = section
    end 
    ::continue::
  end 
  --print(memory_map_dump(args.state.sections))
  --print(memory_map_dump(memory_map))
  --print(aoc.dump(memory_map[#memory_map]))

  return checksum(memory_map) 
end 

-- local function part2(args)
--   local moved = {} 
--   local memory_map =  
--   for i,section in ipairs(args.state.sections) do 
--     print("===", aoc.dump(section))
--     if section.free then 
--       local free = section 
--       print(">> Filling free sector")
--       while free ~= nil do 
--         local file = find_file(args.state.sections,free.size,moved)
--         if file == nil then
--           -- Move the file 
--           memory_map[#memory_map+1] = free
--           goto continue 
--         end 
--         print("> Moving: " ..  file.id)
--         local insert = nil
--         insert,free = insert_chunk(free,file)
--         assert(free == nil or free.free, "Insert_chunk should only have nil or free sections left")
--         assert(insert.size == file.size, "The section inserted should be the same size as the file taken ")
--         moved[file.id] = true
--         memory_map[#memory_map+1] = insert
--       end 
--     else 
--       if moved[section.id] ~=nil then goto continue end 
--       print(">> Placing file")
--       print("> " .. section.id)
--       moved[section.id] = true 
--       memory_map[#memory_map+1] = section
--     end 
--     ::continue::
--   end 
--   print(memory_map_dump(args.state.sections))
--   print(memory_map_dump(memory_map))
--   --print(aoc.dump(memory_map[#memory_map]))
--
--   return checksum(memory_map) 
--   
-- end
-- 0 0 9 9 2 1 1 1 7 7 7 . 4 4 . 3 3 3 . . . . 5 5 5 5 . 6 6 6 6 . . . . . 8 8 8 8 . .
-- 0 0 9 9 2 1 1 1 7 7 7 4 4 . 3 3 3 . . 5 5 5 5 . 6 6 6 6 . . 8 8 8 8 
-- 0099811188827773336446555566..............
local day9 = aoc.create(9) 
day9:run(init, {}, 9)
day9:run(part1, {}, 1928)
-- day9:run(part2, {}, 2858)
