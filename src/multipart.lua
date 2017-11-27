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

local function table_size(t)
  local res = 0
  if t then
    for _,_ in pairs(t) do
      res = res + 1
    end
  end
  return res
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
  local part_name, part_value, part_value_ct
  local processing_part_value = false
  part_value = {}
  part_value_ct = 0

  local position = 1
  local done = false

  repeat

    local s = string.find(body, "[\r\n]", position)

    local line

    if s then
      line = string.sub(body, position, s - 1)
      position = s + 1
    else
      if position == 1 then
        line = body
      else
        line = string.sub(body, position)
      end

      done = true
    end

    if line == "" then
      if processing_part_value then
        part_value_ct = part_value_ct + 1
        part_value[part_value_ct] = string.sub(body, s, s)
      end
    else
      if line:sub(1, 2) == "--" and line:sub(3, #boundary+2) == boundary then
        processing_part_value = false

        if part_name ~= nil then
          if part_value[part_value_ct] == "\n" then
            part_value[part_value_ct] = nil
          end

          if part_value[part_value_ct-1] == "\r" then
            part_value[part_value_ct-1] = nil
          end

          result.data[part_index] = {
            name = part_name,
            headers = part_headers,
            value = table.concat(part_value)
          }

          result.indexes[part_name] = part_index

          -- Reset fields for the next part
          part_headers = {}
          part_value = {}
          part_value_ct = 0
          part_name = nil
          part_index = part_index + 1
        end
      elseif line:sub(1, 19):lower() == "content-disposition" then --Beginning of part
        processing_part_value = false

        -- Extract part_name
        for v in line:gmatch("[^;]+") do
          if not is_header(v) then -- If it's not content disposition part
            local pos = v:match("^%s*[Nn][Aa][Mm][Ee]=()")
            if pos then
              local current_value = v:match("^%s*([^=]*)", pos):gsub("%s*$", "")
              part_name = string.sub(current_value, 2, string.len(current_value) - 1)
            end
          end
        end
        table.insert(part_headers, line)
      else
        if is_header(line) then
          processing_part_value = false
          table.insert(part_headers, line)
        else
          processing_part_value = true
          -- The value part begins
          part_value_ct = part_value_ct + 1
          part_value[part_value_ct] = line
          if s then
            part_value_ct = part_value_ct + 1
            part_value[part_value_ct] = string.sub(body, s, s)
          end
        end
      end
    end

  until done

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
  if content_type then
    instance._boundary = string.match(content_type, ";%s*boundary=(%S+)")
  end
  instance._data = decode(data or "", instance._boundary)
  return instance
end

function MultipartData:get(name)
  return self._data.data[self._data.indexes[name]]
end

function MultipartData:get_all()
  local result = {}
  for k, v in pairs(self._data.indexes) do
    result[k] = self._data.data[v].value
  end
  return result
end

function MultipartData:set_simple(name, value)
  if self._data.indexes[name] then
    self._data.data[self._data.indexes[name]] = {
      name = name,
      value = value,
      headers = { "Content-Disposition: form-data; name=\""..name.."\"" }
    }
  else
    local part_index = table_size(self._data.indexes) + 1
    self._data.indexes[name] = part_index
    self._data.data[part_index] = {
      name = name,
      value = value,
      headers = { "Content-Disposition: form-data; name=\""..name.."\"" }
    }
  end
end

function MultipartData:delete(name)
  if self._data.indexes[name] then
    self._data.data[self._data.indexes[name]].value = nil
    self._data.indexes[name] = nil
  end
end

function MultipartData:tostring()
  return encode(self._data, self._boundary)
end

return MultipartData
