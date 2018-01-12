local Multipart = require "multipart"

local function table_size(t)
  local res = 0
  if t then
    for _,_ in pairs(t) do
      res = res + 1
    end
  end
  return res
end

describe("Multipart Tests", function()

  it("should not fail with request that don't have a body", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local res = Multipart(nil, content_type)
    assert.truthy(res)
  end)

  it("should not fail with request that don't have a content-type header", function()
    local res = Multipart(nil, nil)
    assert.truthy(res)
  end)

  it("should decode a multipart/related body", function()

    local content_type = "multipart/related; boundary=AaB03x"
    local body = ([[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello

planetCRLFearth
--AaB03x--]]):gsub("CRLF", "\r\n")

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local internal_data = res._data

    -- Check internals
    local index = internal_data.indexes["submit-name"]
    assert.truthy(index)
    assert.are.same(1, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    index = internal_data.indexes["files"]
    assert.truthy(index)
    assert.are.same(2, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file1.txt ...\nhello\n\nplanet\r\nearth", internal_data.data[index].value)

    -- Check interface

    local param = res:get("submit-name")
    assert.truthy(param)
    assert.are.same("submit-name", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, param.headers)
    assert.are.same("Larry", param.value)

    param = res:get("files")
    assert.truthy(param)
    assert.are.same("files", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, param.headers)
    assert.are.same("... contents of file1.txt ...\nhello\n\nplanet\r\nearth", param.value)

  end)

  it("should decode a multipart body", function()

    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local internal_data = res._data

    -- Check internals
    local index = internal_data.indexes["submit-name"]
    assert.truthy(index)
    assert.are.same(1, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    index = internal_data.indexes["files"]
    assert.truthy(index)
    assert.are.same(2, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file1.txt ...\nhello", internal_data.data[index].value)

    -- Check interface

    local param = res:get("submit-name")
    assert.truthy(param)
    assert.are.same("submit-name", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, param.headers)
    assert.are.same("Larry", param.value)

    param = res:get("files")
    assert.truthy(param)
    assert.are.same("files", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, param.headers)
    assert.are.same("... contents of file1.txt ...\nhello", param.value)

    local all = res:get_all()

    assert.are.same(2, table_size(all))
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("... contents of file1.txt ...\nhello", all["files"])
  end)

  it("should decode a multipart body with headers in body", function()
    local content_type = "multipart/form-data;boundary=AaB03x"
    local body         = '--AaB03x\r\n' ..
                         'Content-Disposition:form-data;name="submit-name"\r\n\r\n' ..
                         '\r\n\r\nLarry\r\n\r\nContent-Disposition:form-data\r\n\r\n\r\n' ..
                         '--AaB03x--\r\n'

    local res = Multipart(body, content_type)

    assert.truthy(res)

    local internal_data = res._data

    local index = internal_data.indexes["submit-name"]
    assert.truthy(index)
    assert.are.same(1, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition:form-data;name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("\r\n\r\nLarry\r\n\r\nContent-Disposition:form-data\r\n\r\n", internal_data.data[index].value)
  end)

  it("should decode a multipart body with multiple headers in body", function()
    local content_type = "multipart/form-data;boundary=AaB03x"
    local body         = '--AaB03x\r\n' ..
                         'Content-Disposition:form-data;name="submit-name"\r\n' ..
                         'Content-Type:text/plain\r\n\r\n' ..
                         '\r\n\r\nLarry\r\n\r\nContent-Disposition:form-data\r\n\r\n\r\n' ..
                         '--AaB03x--\r\n'

    local res = Multipart(body, content_type)

    assert.truthy(res)

    local internal_data = res._data

    local index = internal_data.indexes["submit-name"]
    assert.truthy(index)
    assert.are.same(1, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({
      'Content-Disposition:form-data;name="submit-name"',
      'Content-Type:text/plain',
    }, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("\r\n\r\nLarry\r\n\r\nContent-Disposition:form-data\r\n\r\n", internal_data.data[index].value)
  end)

  it("should decode a multipart body without header whitespace", function()

    local content_type = "multipart/form-data;boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition:form-data;name="submit-name"

Larry
--AaB03x
Content-Disposition:form-data;name="files";filename="file1.txt"
Content-Type:text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local internal_data = res._data

    -- Check internals
    local index = internal_data.indexes["submit-name"]
    assert.truthy(index)
    assert.are.same(1, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition:form-data;name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    index = internal_data.indexes["files"]
    assert.truthy(index)
    assert.are.same(2, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition:form-data;name=\"files\";filename=\"file1.txt\"", "Content-Type:text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file1.txt ...\nhello", internal_data.data[index].value)

    -- Check interface

    local param = res:get("submit-name")
    assert.truthy(param)
    assert.are.same("submit-name", param.name)
    assert.are.same({"Content-Disposition:form-data;name=\"submit-name\""}, param.headers)
    assert.are.same("Larry", param.value)

    param = res:get("files")
    assert.truthy(param)
    assert.are.same("files", param.name)
    assert.are.same({"Content-Disposition:form-data;name=\"files\";filename=\"file1.txt\"", "Content-Type:text/plain"}, param.headers)
    assert.are.same("... contents of file1.txt ...\nhello", param.value)

    local all = res:get_all()

    assert.are.same(2, table_size(all))
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("... contents of file1.txt ...\nhello", all["files"])
  end)

  it("should encode a multipart body", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local data = res:tostring()

    -- The strings should be the same, but \n needs to be replaced with \r\n
    --local replace_new_lines, _ = string.gsub(body, "\n", "\r\n")
    assert.are.same(table.concat({
      '--AaB03x',
      'Content-Disposition: form-data; name="submit-name"',
      '',
      'Larry',
      '--AaB03x',
      'Content-Disposition: form-data; name="files"; filename="file1.txt"',
      'Content-Type: text/plain',
      '',
      '... contents of file1.txt ...\nhello',
      '--AaB03x--\r\n',
    }, "\r\n"), data)
  end)

  it("should delete a parameter", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--
]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    res:delete("submit-name")

    local data = res:tostring()

    assert.are.same(table.concat({
      '--AaB03x',
      'Content-Disposition: form-data; name="files"; filename="file1.txt"',
      'Content-Type: text/plain',
      '',
      '... contents of file1.txt ...\nhello',
      '--AaB03x--',
      '',
    }, "\r\n"), data)
  end)

  it("should delete the last parameter", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    res:delete("files")

    local data = res:tostring()

    -- The strings should be the same, but \n needs to be replaced with \r\n
    local replace_new_lines, _ = string.gsub([[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x--
]], "\n", "\r\n")
    assert.are.same(data, replace_new_lines)
  end)

  it("should encode a multipart body", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local new_body = table.concat({
    '--AaB03x',
    'Content-Disposition: form-data; name="submit-name"',
    '',
    'Larry',
    '--AaB03x',
    'Content-Disposition: form-data; name="files"; filename="file1.txt"',
    'Content-Type: text/plain',
    '',
    '... contents of file1.txt ...\nhello',
    '--AaB03x',
    'Content-Disposition: form-data; name="hello"',
    '',
    'world :)',
    '--AaB03x',
    'Content-Disposition: form-data; name="hello2"',
    '',
    'world2 :)',
    '--AaB03x--\r\n',
    }, "\r\n")

    local res = Multipart(body, content_type)
    assert.truthy(res)

    res:set_simple("hello", "world :)")
    res:set_simple("hello2", "world2 :)")

    local data = res:tostring()
    assert.are.same(#new_body, #data)
  end)

end)
