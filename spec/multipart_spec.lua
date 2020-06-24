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

  it("should decode a boundary", function()
    local content_type = "multipart/related; boundary=AaB03x"
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same("AaB03x", res._boundary)
  end)

  it("should not crash with missing boundary", function()
    local content_type = "multipart/related;"
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same(nil, res._boundary)
  end)

  it("should not crash with empty boundary", function()
    local content_type = "multipart/related; boundary="
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same(nil, res._boundary)
  end)

  it("should not crash with empty single quoted boundary", function()
    local content_type = "multipart/related; boundary=''"
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same(nil, res._boundary)
  end)

  it("should not crash with empty double quoted boundary", function()
    local content_type = 'multipart/related; boundary=""'
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same(nil, res._boundary)
  end)

  it("should decode a single quoted boundary", function()
    local content_type = "multipart/related; boundary='AaB03x'"
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same("AaB03x", res._boundary)
  end)

  it("should decode a double quoted boundary", function()
    local content_type = 'multipart/related; boundary="AaB03x"'
    local body = ""

    local res = Multipart(body, content_type)
    assert.truthy(res)
    assert.are.same("AaB03x", res._boundary)
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
    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    indexes = internal_data.indexes["files"]
    assert.truthy(indexes)
    index = indexes[1]
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
    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    indexes = internal_data.indexes["files"]
    assert.truthy(indexes)
    index = indexes[1]
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

  it("should decode a multipart body with multiple file parts and missing and repeating filename", function()

    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file2.txt ...
--AaB03x
Content-Disposition: form-data; name="files";
Content-Type: text/plain

... contents of file3.txt ...
--AaB03x
Content-Disposition: form-data; name="files";
Content-Type: text/plain

... contents of file4.txt ...
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local internal_data = res._data

    -- Check internals
    local indexes = internal_data.indexes["files"]
    assert.truthy(indexes)
    assert.are.same({1, 2, 3, 4}, indexes)
    local index = indexes[1]
    assert.truthy(index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file1.txt ...", internal_data.data[index].value)

    index = indexes[2]
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file2.txt ...", internal_data.data[index].value)

    index = indexes[3]
    assert.truthy(index)
    assert.are.same(3, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\";", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file3.txt ...", internal_data.data[index].value)

    index = indexes[4]
    assert.truthy(index)
    assert.are.same(4, index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("files", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"files\";", "Content-Type: text/plain"}, internal_data.data[index].headers)
    assert.are.same(2, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("... contents of file4.txt ...", internal_data.data[index].value)

    -- Check interface
    local param = res:get("files")
    assert.truthy(param)
    assert.are.same("files", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"", "Content-Type: text/plain"}, param.headers)
    assert.are.same("... contents of file1.txt ...", param.value)

    local all = res:get_all()

    assert.are.same(1, table_size(all))
    assert.are.same("... contents of file1.txt ...", all["files"])

    local as_array = res:get_as_array("files")
    assert.truthy(as_array)
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
      "... contents of file3.txt ...",
      "... contents of file4.txt ...",
    }, as_array)

    local as_array_all = res:get_all_with_arrays()
    assert.truthy(as_array_all)
    as_array = as_array_all["files"]
    assert.truthy(as_array)
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
      "... contents of file3.txt ...",
      "... contents of file4.txt ...",
    }, as_array)

    local with_array_all = res:get_all_as_arrays()
    assert.truthy(with_array_all)
    with_array = with_array_all["files"]
    assert.truthy(with_array)
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
      "... contents of file3.txt ...",
      "... contents of file4.txt ...",
    }, with_array)
  end)

  it("should decode invalid empty multipart body", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = "--\n"
    local res = Multipart(body, content_type)
    assert.truthy(res)
    local internal_data = res._data
    local all = res:get_all()
    assert.are.same(0, table_size(all))
  end)

  it("should decode invalid empty multipart body with headers", function()

    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local internal_data = res._data

    -- Check internals
    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("", internal_data.data[index].value)

    -- Check interface

    local param = res:get("submit-name")
    assert.truthy(param)
    assert.are.same("submit-name", param.name)
    assert.are.same({"Content-Disposition: form-data; name=\"submit-name\""}, param.headers)
    assert.are.same("", param.value)

    local all = res:get_all()

    assert.are.same(1, table_size(all))
    assert.are.same("", all["submit-name"])
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

    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
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

    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
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
    local indexes = internal_data.indexes["submit-name"]
    assert.truthy(indexes)
    assert.are.same({1}, indexes)
    local index = indexes[1]
    assert.truthy(index)
    assert.truthy(internal_data.data[index])
    assert.truthy(internal_data.data[index].name)
    assert.are.same("submit-name", internal_data.data[index].name)
    assert.truthy(internal_data.data[index].headers)
    assert.are.same({"Content-Disposition:form-data;name=\"submit-name\""}, internal_data.data[index].headers)
    assert.are.same(1, table_size(internal_data.data[index].headers))
    assert.truthy(internal_data.data[index].value)
    assert.are.same("Larry", internal_data.data[index].value)

    indexes = internal_data.indexes["files"]
    assert.truthy(indexes)
    assert.are.same({2}, indexes)
    index = indexes[1]
    assert.truthy(index)
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

  it("should rename a parameter", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="1"

Larry
--AaB03x
Content-Disposition: form-data; name="2"

Jayce
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
hello
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local rename = function(old_name, new_name)
      local value = res:get(old_name).value
      res:delete(old_name)
      res:set_simple(new_name, value)
    end

    rename("1", "submit-name")
    rename("2", "other-name")

    local data = res:tostring()

    assert.are.same(table.concat({
      '--AaB03x',
      'Content-Disposition: form-data; name="files"; filename="file1.txt"',
      'Content-Type: text/plain',
      '',
      '... contents of file1.txt ...\nhello',
      '--AaB03x',
      'Content-Disposition: form-data; name="submit-name"',
      '',
      'Larry',
      '--AaB03x',
      'Content-Disposition: form-data; name="other-name"',
      '',
      'Jayce',
      '--AaB03x--',
      '',
    }, "\r\n"), data)
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

  it("should encode a multipart body file with set param used", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x
Content-Disposition: form-data; name="files"; filename="file2.txt"
Content-Type: text/plain

... contents of file2.txt ...
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
    '... contents of file1.txt ...',
    '--AaB03x',
    'Content-Disposition: form-data; name="files"; filename="file2.txt"',
    'Content-Type: text/plain',
    '',
    '... contents of file2.txt ...',
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
    assert.are.same(new_body, data)
  end)

  it("should encode a multipart body file with set param used and same filename and skipped filename", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file2.txt ...
--AaB03x
Content-Disposition: form-data; name="files";
Content-Type: text/plain

... contents of file3.txt ...
--AaB03x
Content-Disposition: form-data; name="files";
Content-Type: text/plain

... contents of file4.txt ...
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
    '... contents of file1.txt ...',
    '--AaB03x',
    'Content-Disposition: form-data; name="files"; filename="file1.txt"',
    'Content-Type: text/plain',
    '',
    '... contents of file2.txt ...',
    '--AaB03x',
    'Content-Disposition: form-data; name="files";',
    'Content-Type: text/plain',
    '',
    '... contents of file3.txt ...',
    '--AaB03x',
    'Content-Disposition: form-data; name="files";',
    'Content-Type: text/plain',
    '',
    '... contents of file4.txt ...',
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
    assert.are.same(new_body, data)
  end)

end)

it("should encode a multipart body with invalid boundary in parsed one", function()
  local content_type = "multipart/form-data; boundary="
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

  local new_body = table.concat({
    '--' .. Multipart.RANDOM_BOUNDARY,
    'Content-Disposition: form-data; name="hello"',
    '',
    'world :)',
    '--' .. Multipart.RANDOM_BOUNDARY,
    'Content-Disposition: form-data; name="hello2"',
    '',
    'world2 :)',
    '--' .. Multipart.RANDOM_BOUNDARY .. '--\r\n',
  }, "\r\n")

  local res = Multipart(body, content_type)
  assert.truthy(res)

  res:set_simple("hello", "world :)")
  res:set_simple("hello2", "world2 :)")

  local data = res:tostring()
  assert.are.same(new_body, data)
end)

it("set a file example", function()
    local content_type = "multipart/related; boundary=0f755aa8"
    local body = ""
    local res = Multipart(body, content_type)
    local f = io.open("./spec/example.txt", "rb")
    local value = f:read("*all")
    f:close()
    res:set_simple("example", value, "example.txt", "text/txt")
    local body = res:tostring()
    local example_body = table.concat({
        "--0f755aa8",
        'Content-Disposition: form-data; name="example"; filename="example.txt"',"content-type: text/txt", "\r\nhello world\n", "--0f755aa8--\r\n"
    }, "\r\n")
    assert.are.same(example_body, body)
end)

it("for repeating part_names test get, get_as_array, get_all, get_all_as_arrays, get_all_with_arrays", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x
Content-Disposition: form-data; name="files"
Content-Type: text/plain

... contents of file2.txt ...
--AaB03x
Content-Disposition: form-data; name="hello"

world :)
--AaB03x
Content-Disposition: form-data; name="hello2"

world2 :)
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    -- get should return fist occurance for repeating part names
    assert.are.same("... contents of file1.txt ...", res:get("files").value)
    assert.are.same("Larry", res:get("submit-name").value)
    assert.are.same("world :)", res:get("hello").value)
    assert.are.same("world2 :)", res:get("hello2").value)

    local all = res:get_all()
    assert.are.same(4, table_size(all))
    assert.are.same("... contents of file1.txt ...", all["files"])
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("world :)", all["hello"])
    assert.are.same("world2 :)", all["hello2"])

    all = res:get_all_with_arrays()
    assert.are.same(4, table_size(all))
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
    }, all["files"])
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("world :)", all["hello"])
    assert.are.same("world2 :)", all["hello2"])

    all = res:get_all_as_arrays()
    assert.are.same(4, table_size(all))
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
    }, all["files"])
    assert.are.same({"Larry"}, all["submit-name"])
    assert.are.same({"world :)"}, all["hello"])
    assert.are.same({"world2 :)"}, all["hello2"])
  end)