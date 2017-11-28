package = "multipart"
version = "scm-0"
source = {
  url = "git+https://github.com/Kong/lua-multipart"
}
description = {
  summary = "A simple HTTP multipart encoder/decoder for Lua",
  detailed = [[
    A simple HTTP multipart encoder/decoder for Lua, that can be used to work with multipart/form-data payloads.
  ]],
  homepage = "https://github.com/Kong/lua-multipart",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    multipart = "src/multipart.lua"
  }
}
