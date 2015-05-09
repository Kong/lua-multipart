package = "multipart"
version = "0.1-3"
source = {
  url = "git://github.com/Mashape/lua-multipart",
  tag = "0.1-3"
}
description = {
  summary = "A simple HTTP multipart encoder/decoder for Lua",
  detailed = [[
    A simple HTTP multipart encoder/decoder for Lua, that can be used to work with multipart/form-data payloads.
  ]],
  homepage = "https://github.com/Mashape/lua-multipart",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "stringy ~> 0.4-1"
}
build = {
  type = "builtin",
  modules = {
    multipart = "src/multipart.lua"
  }
}
