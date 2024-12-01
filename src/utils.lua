
function getfile(filename)
  local file = assert(io.open(filename, "rb"))
  local content = file:read("*all")

  return content
end

function data(day, partn)
  return {
    example =  getfile("data/day" .. day .. "/example" .. partn ..".txt"),
    ex_res = getfile("data/day" .. day .. "/ex_res" .. partn .. ".txt"),
    input = getfile("data/day" .. day .. "/input" .. partn .. ".txt"),
  }
end

return {
  data = data,
}
