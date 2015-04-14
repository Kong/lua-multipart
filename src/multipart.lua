
local stringy = require "stringy"

local MultipartData = {}
MultipartData.__index = MultipartData

setmetatable(MultipartData, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local function is_header(value)
  return string.match(value, "(%S+):%s*(%S+)")
end

local function starts_with(full_str, val)
  return string.sub(full_str, 0, string.len(val)) == val
end

-- Create a table representation of multipart/data body
--
-- @param {string} body The multipart/data string body
-- @param {string} boundary The multipart/data boundary
-- @return {table} Lua representation of the body
local function decode(body, boundary)
  local result = {
    data = {},
    indexes = {}
  }

  local part_headers = {}
  local part_index = 1
  local part_name, part_value

  for line in body:gmatch("[^\r\n]+") do
    if starts_with(line, "--"..boundary) then
      if part_name ~= nil then
        result.data[part_index] = {
          name = part_name,
          headers = part_headers,
          value = part_value
        }

        result.indexes[part_name] = part_index

        -- Reset fields for the next part
        part_headers = {}
        part_value = nil
        part_name = nil
        part_index = part_index + 1
      end
    elseif starts_with(string.lower(line), "content-disposition") then --Beginning of part
      -- Extract part_name
      local parts = stringy.split(line, ";")
      for _,v in ipairs(parts) do
        if not is_header(v) then -- If it's not content disposition part
          local current_parts = stringy.split(stringy.strip(v), "=")
          if string.lower(table.remove(current_parts, 1)) == "name" then
             local current_value = stringy.strip(table.remove(current_parts, 1))
             part_name = string.sub(current_value, 2, string.len(current_value) - 1)
          end
        end
      end
      table.insert(part_headers, line)
    else
      if is_header(line) then
        table.insert(part_headers, line)
      else
        -- The value part begins
        part_value = (part_value and part_value.."\r\n" or "")..line
      end
    end
  end
  return result
end

-- Creates a multipart/data body from a table
--
-- @param {table} t The table that contains the multipart/data body properties
-- @param {boundary} boundary The multipart/data boundary to use
-- @return {string} The multipart/data string body
local function encode(t, boundary)
  local result = ""

  for _, v in ipairs(t.data) do
    if v.value then
      local part = "--"..boundary.."\r\n"
      for _, header in ipairs(v.headers) do
        part = part..header.."\r\n"
      end
      result = result..part.."\r\n"..v.value.."\r\n"
    end
  end
  result = result.."--"..boundary.."--"

  return result
end

function MultipartData.new(data, content_type)
  local instance = {}
  setmetatable(instance, MultipartData)
  instance._boundary = string.match(content_type, ";%s+boundary=(%S+)")
  instance._data = decode(data, instance._boundary)
  return instance
end

function MultipartData:get(name)
  return self._data.data[self._data.indexes[name]]
end

function MultipartData:set_simple(name, value)
  self._data.data[self._data.indexes[name]] = {
    name = name,
    value = value,
    headers = { "Content-Disposition: form-data; name=\""..name.."\"" }
  }
end

function MultipartData:delete(name)
  if self._data.indexes[name] then
    self._data.data[self._data.indexes[name]].value = nil
  end
end

function MultipartData:tostring()
  return encode(self._data, self._boundary)
end

return MultipartData
