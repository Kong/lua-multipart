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

    local param = res:get("inexistent")
    assert.is_nil(param)

    local param = res:get_as_array("inexistent")
    assert.same({}, param)
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


    local param = res:get("inexistent")
    assert.is_nil(param)

    local param = res:get_as_array("inexistent")
    assert.same({}, param)


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
    local with_array = with_array_all["files"]
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

  it("should decode a multipart body with unquoted field names", function()
    local content_type = "multipart/form-data; boundary=AaB03x"
    local body = [[
--AaB03x
Content-Disposition: form-data; name=login_id

larry123
--AaB03x
Content-Disposition: form-data; name=api_key

secret456
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    local param = res:get("login_id")
    assert.truthy(param)
    assert.are.same("login_id", param.name)
    assert.are.same("larry123", param.value)

    param = res:get("api_key")
    assert.truthy(param)
    assert.are.same("api_key", param.name)
    assert.are.same("secret456", param.value)

    local all = res:get_all()
    assert.are.same(2, table_size(all))
    assert.are.same("larry123", all["login_id"])
    assert.are.same("secret456", all["api_key"])
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

it("for repeating part_names test get, get_as_array, get_all, get_all_as_arrays, get_all_with_arrays, get_all_include_headers_with_arrays", function()
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
--AaB03x
Content-Disposition: attachment; name="files-utf8"; filename="simple.txt"; filename*=UTF-8''%E4%BE%8B%E5%AD%90.txt
Content-Type: text/plain

... contents of simple.txt ...
--AaB03x
Content-Disposition: form-data; name="uploadFile"; filename*=UTF-8''%E3%83%95%E3%82%A7%E3%83%8B%E3%83%83%E3%82%AF%E3%82%B9.jpg
Content-Type: image/jpeg

... contents of uploadFile.jpg ...
--AaB03x--]]

    local res = Multipart(body, content_type)
    assert.truthy(res)

    -- get should return fist occurance for repeating part names
    assert.are.same("... contents of file1.txt ...", res:get("files").value)
    assert.are.same("Larry", res:get("submit-name").value)
    assert.are.same("world :)", res:get("hello").value)
    assert.are.same("world2 :)", res:get("hello2").value)
    assert.are.same("... contents of simple.txt ...", res:get("files-utf8").value)
    assert.are.same("... contents of uploadFile.jpg ...", res:get("uploadFile").value)

    local all = res:get_all()
    assert.are.same(6, table_size(all))
    assert.are.same("... contents of file1.txt ...", all["files"])
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("world :)", all["hello"])
    assert.are.same("world2 :)", all["hello2"])
    assert.are.same("... contents of simple.txt ...", all["files-utf8"])
    assert.are.same("... contents of uploadFile.jpg ...", all["uploadFile"])

    all = res:get_all_with_arrays()
    assert.are.same(6, table_size(all))
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
    }, all["files"])
    assert.are.same("Larry", all["submit-name"])
    assert.are.same("world :)", all["hello"])
    assert.are.same("world2 :)", all["hello2"])
    assert.are.same("... contents of simple.txt ...", all["files-utf8"])
    assert.are.same("... contents of uploadFile.jpg ...", all["uploadFile"])

    all = res:get_all_as_arrays()
    assert.are.same(6, table_size(all))
    assert.are.same({
      "... contents of file1.txt ...",
      "... contents of file2.txt ...",
    }, all["files"])
    assert.are.same({"Larry"}, all["submit-name"])
    assert.are.same({"world :)"}, all["hello"])
    assert.are.same({"world2 :)"}, all["hello2"])
    assert.are.same({"... contents of simple.txt ..."}, all["files-utf8"])
    assert.are.same({"... contents of uploadFile.jpg ..."}, all["uploadFile"])

    local all_with_headers = res:get_all_include_headers_with_arrays()
    assert.are.same(6, table_size(all_with_headers))
    assert.are.same("... contents of file1.txt ...", all_with_headers["files"][1].value)
    assert.are.same("... contents of file2.txt ...", all_with_headers["files"][2].value)
    assert.are.same('form-data; name="submit-name"', all_with_headers["submit-name"][1].headers["content-disposition"])
    assert.are.same("... contents of simple.txt ...", all_with_headers["files-utf8"][1].value)
    assert.are.same([[attachment; name="files-utf8"; filename="simple.txt"; filename*=UTF-8''%E4%BE%8B%E5%AD%90.txt]], all_with_headers["files-utf8"][1].headers["content-disposition"])
    assert.are.same([[form-data; name="uploadFile"; filename*=UTF-8''%E3%83%95%E3%82%A7%E3%83%8B%E3%83%83%E3%82%AF%E3%82%B9.jpg]], all_with_headers["uploadFile"][1].headers["content-disposition"])
    assert.are.same("... contents of uploadFile.jpg ...", all_with_headers["uploadFile"][1].value)

    assert.are.same('form-data; name="files"; filename="file1.txt"', all_with_headers["files"][1].headers["content-disposition"])
    assert.are.same('form-data; name="files"', all_with_headers["files"][2].headers["content-disposition"])

    assert.are.same("Larry", all_with_headers["submit-name"][1].value)
    assert.are.same("world :)", all_with_headers["hello"][1].value)
    assert.are.same("world2 :)", all_with_headers["hello2"][1].value)
  end)

describe("Multipart decoding edge cases", function()
  local CT = "multipart/form-data; boundary=AaB03x"

  local function crlf(...)
    return table.concat({ ... }, "\r\n")
  end

  local function sizeof(t)
    local n = 0
    for _ in pairs(t) do
      n = n + 1
    end
    return n
  end

  describe("part names", function()
    for _, name in ipairs({ "a:b", "x: y", "urn:a:b", "<http://e.com/x>" }) do
      it("should decode a part whose name contains a colon: " .. name, function()
        local body = crlf(
          "--AaB03x",
          'Content-Disposition: form-data; name="note"',
          "",
          "hello",
          "--AaB03x",
          'Content-Disposition: form-data; name="' .. name .. '"',
          "Content-Type: application/json",
          "",
          '{"a":1}',
          "--AaB03x--",
          "")

        local res = Multipart(body, CT)

        local param = res:get(name)
        assert.truthy(param)
        assert.are.same(name, param.name)
        assert.are.same('{"a":1}', param.value)
        assert.are.same("hello", res:get("note").value)
        assert.are.same(2, sizeof(res:get_all()))

        local with_headers = res:get_all_include_headers_with_arrays()
        assert.are.same("application/json", with_headers[name][1].headers["content-type"])
      end)
    end

    it("should decode an unquoted name that contains a colon", function()
      local body = crlf(
        "--AaB03x",
        "Content-Disposition: form-data; name=a:b",
        "",
        "value",
        "--AaB03x--",
        "")

      assert.are.same("value", Multipart(body, CT):get("a:b").value)
    end)

    it("should decode a quoted name that contains a semicolon", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="x;y"; filename="f.txt"',
        "",
        "value",
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      assert.are.same("value", res:get("x;y").value)
      assert.are.same(1, sizeof(res:get_all()))
    end)

    it("should decode a quoted name that contains an escaped quote", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="a\\"b"',
        "",
        "value",
        "--AaB03x--",
        "")

      assert.are.same("value", Multipart(body, CT):get('a"b').value)
    end)

    it("should find the name when it follows another parameter", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; filename="f:1.txt"; name="file"',
        "",
        "value",
        "--AaB03x--",
        "")

      assert.are.same("value", Multipart(body, CT):get("file").value)
    end)

    it("should not take a parameter whose name only ends with name as the part name", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; username="u"; name="n"',
        "",
        "value",
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      assert.are.same("value", res:get("n").value)
      assert.is_nil(res:get("u"))
    end)
  end)

  describe("delimiters", function()
    it("should not split a part at a line that only starts with the boundary", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "Content-Type: application/json",
        "",
        '{"a":"ok"}',
        "--AaB03xX",
        'Content-Disposition: form-data; name="x"',
        "",
        "hidden",
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)

      assert.are.same(1, sizeof(res:get_all()))
      assert.are.same(
        '{"a":"ok"}\r\n--AaB03xX\r\nContent-Disposition: form-data; name="x"\r\n\r\nhidden',
        res:get("meta").value)
    end)

    it("should accept trailing whitespace after a delimiter", function()
      local body = crlf(
        "--AaB03x \t",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--AaB03x  ",
        'Content-Disposition: form-data; name="b"',
        "",
        "2",
        "--AaB03x-- \t",
        "")

      local res = Multipart(body, CT)
      assert.are.same("1", res:get("a").value)
      assert.are.same("2", res:get("b").value)
      assert.are.same(2, sizeof(res:get_all()))
    end)

    it("should keep every part when the closing delimiter is missing", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "",
        "first",
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "",
        "second")

      local res = Multipart(body, CT)
      assert.are.same({ "first", "second" }, res:get_as_array("meta"))
      assert.are.same(2, #res:get_all_include_headers_with_arrays().meta)
    end)

    it("should ignore a preamble before the first delimiter", function()
      local body = crlf(
        "This is the preamble",
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "",
        "value",
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      assert.are.same("value", res:get("meta").value)
      assert.are.same(1, sizeof(res:get_all()))
    end)

    it("should not decode a part from a preamble", function()
      local body = crlf(
        'Content-Disposition: form-data; name="evil"',
        "",
        "payload",
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "",
        "value",
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      assert.is_nil(res:get("evil"))
      assert.are.same("value", res:get("meta").value)
    end)

    it("should ignore an epilogue after the closing delimiter", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--AaB03x--",
        'Content-Disposition: form-data; name="b"',
        "",
        "2",
        "")

      local res = Multipart(body, CT)
      assert.is_nil(res:get("b"))
      assert.are.same(1, sizeof(res:get_all()))
      assert.are.same("1", res:get("a").value)
    end)
  end)

  describe("boundary parameter", function()
    local body = crlf(
      "--AaB03x",
      'Content-Disposition: form-data; name="a"',
      "",
      "1",
      "--AaB03x--",
      "")

    for _, content_type in ipairs({
      "multipart/form-data; Boundary=AaB03x",
      "multipart/form-data; BOUNDARY=AaB03x",
      "multipart/form-data;boundary=AaB03x",
      "multipart/form-data; boundary=AaB03x;charset=utf-8",
      "multipart/form-data; boundary=AaB03x; charset=utf-8",
      "multipart/form-data; charset=utf-8; boundary=AaB03x",
      'multipart/form-data; boundary="AaB03x"; charset=utf-8',
      "multipart/form-data; boundary='AaB03x'; charset=utf-8",
      "multipart/form-data; boundary=AaB03x ",
    }) do
      it("should decode the boundary in: " .. content_type, function()
        local res = Multipart(body, content_type)
        assert.truthy(res:get("a"))
        assert.are.same("1", res:get("a").value)
      end)
    end

    it("should decode a quoted boundary that contains a space", function()
      local spaced = crlf(
        "--a b",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--a b--",
        "")

      local res = Multipart(spaced, 'multipart/form-data; boundary="a b"; charset=utf-8')
      assert.are.same("1", res:get("a").value)
    end)

    it("should decode a quoted boundary that contains a semicolon", function()
      local semi = crlf(
        "--a;b",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--a;b--",
        "")

      local res = Multipart(semi, 'multipart/form-data; boundary="a;b"')
      assert.are.same("1", res:get("a").value)
    end)

    it("should use the first boundary parameter", function()
      local res = Multipart(body, "multipart/form-data; boundary=AaB03x; boundary=Other")
      assert.are.same("1", res:get("a").value)
    end)

    it("should not decode a parameter whose name only ends with boundary", function()
      local res = Multipart(body, "multipart/form-data; xboundary=AaB03x")
      assert.is_nil(res:get("a"))
    end)
  end)

  describe("parts without a name", function()
    it("should not merge a part without a name into the next part", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: text/plain",
        "",
        "unnamed",
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)

      assert.are.same('{"a":1}', res:get("meta").value)
      assert.are.same(1, sizeof(res:get_all()))
      local with_headers = res:get_all_include_headers_with_arrays()
      assert.are.same("application/json", with_headers.meta[1].headers["content-type"])
    end)

    it("should not add a part without a name to the named views", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      assert.are.same({}, res:get_all())
      assert.are.same({}, res:get_all_with_arrays())
      assert.are.same({}, res:get_all_include_headers_with_arrays())
    end)

    it("should not re-encode a part without a name", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--AaB03x--",
        "")

      local encoded = Multipart(body, CT):tostring()
      assert.is_nil(encoded:find("application/json", 1, true))
      assert.truthy(encoded:find('name="a"', 1, true))
    end)
  end)

  describe("get_parts()", function()
    it("should return every part in body order, with and without a name", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "Content-Type: application/xml",
        "",
        "<a/>",
        "--AaB03x",
        "Content-Type: text/plain",
        "",
        "tail",
        "--AaB03x--",
        "")

      local parts = Multipart(body, CT):get_parts()

      assert.are.same(3, #parts)

      assert.is_nil(parts[1].name)
      assert.are.same('{"a":1}', parts[1].value)
      assert.are.same({
        { name = "content-type", value = "application/json" },
      }, parts[1].headers)

      assert.are.same("meta", parts[2].name)
      assert.are.same("<a/>", parts[2].value)
      assert.are.same({
        { name = "content-disposition", value = 'form-data; name="meta"' },
        { name = "content-type", value = "application/xml" },
      }, parts[2].headers)

      assert.is_nil(parts[3].name)
      assert.are.same("tail", parts[3].value)
      assert.are.same({
        { name = "content-type", value = "text/plain" },
      }, parts[3].headers)
    end)

    it("should keep duplicate headers of a part", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="meta"',
        "Content-Type: application/json",
        "content-type: text/plain",
        "",
        '{"a":1}',
        "--AaB03x--",
        "")

      local res = Multipart(body, CT)
      local parts = res:get_parts()

      assert.are.same({
        { name = "content-disposition", value = 'form-data; name="meta"' },
        { name = "content-type", value = "application/json" },
        { name = "content-type", value = "text/plain" },
      }, parts[1].headers)

      local with_headers = res:get_all_include_headers_with_arrays()
      assert.are.same("text/plain", with_headers.meta[1].headers["content-type"])
    end)

    it("should return repeated names as separate parts", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="f"',
        "",
        "1",
        "--AaB03x",
        'Content-Disposition: form-data; name="f"',
        "",
        "2",
        "--AaB03x--",
        "")

      local parts = Multipart(body, CT):get_parts()
      assert.are.same(2, #parts)
      assert.are.same("1", parts[1].value)
      assert.are.same("2", parts[2].value)
    end)

    it("should return the last part when the closing delimiter is missing", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: application/json",
        "",
        '{"a":1}')

      local parts = Multipart(body, CT):get_parts()
      assert.are.same(1, #parts)
      assert.are.same('{"a":1}', parts[1].value)
    end)

    it("should return a part with a colon in its name", function()
      local body = crlf(
        "--AaB03x",
        'Content-Disposition: form-data; name="a:b"',
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x--",
        "")

      local parts = Multipart(body, CT):get_parts()
      assert.are.same(1, #parts)
      assert.are.same("a:b", parts[1].name)
    end)

    it("should return no parts without a body, a boundary or a delimiter", function()
      assert.are.same({}, Multipart(nil, CT):get_parts())
      assert.are.same({}, Multipart("", CT):get_parts())
      assert.are.same({}, Multipart("x", "multipart/form-data"):get_parts())
      assert.are.same({}, Multipart("no delimiter here", CT):get_parts())
    end)

    it("should return the parts of a multipart/mixed body that has no Content-Disposition", function()
      local body = crlf(
        "--AaB03x",
        "Content-Type: application/json",
        "",
        '{"a":1}',
        "--AaB03x",
        "Content-Type: image/png",
        "",
        "\137PNG",
        "--AaB03x--",
        "")

      local parts = Multipart(body, "multipart/mixed; boundary=AaB03x"):get_parts()
      assert.are.same(2, #parts)
      assert.are.same('{"a":1}', parts[1].value)
      assert.are.same("\137PNG", parts[2].value)
    end)

    it("should decode a part that has no headers", function()
      local body = crlf(
        "--AaB03x",
        "",
        '{"a": 1}',
        "--AaB03x",
        'Content-Disposition: form-data; name="b"',
        "",
        "2",
        "--AaB03x--",
        "")

      local res = Multipart(body, "multipart/mixed; boundary=AaB03x")
      local parts = res:get_parts()

      assert.are.same(2, #parts)
      assert.are.same('{"a": 1}', parts[1].value)
      assert.are.same({}, parts[1].headers)
      assert.are.same("2", res:get("b").value)
    end)

    it("should still decode a body that uses LF line endings only", function()
      local body = table.concat({
        "--AaB03x",
        'Content-Disposition: form-data; name="a"',
        "",
        "1",
        "--AaB03x",
        "Content-Type: text/plain",
        "",
        "unnamed",
        "--AaB03x--",
        "",
      }, "\n")

      local res = Multipart(body, CT)
      local parts = res:get_parts()

      assert.are.same("1", res:get("a").value)
      assert.are.same(2, #parts)
      assert.are.same("unnamed", parts[2].value)
    end)
  end)
end)
