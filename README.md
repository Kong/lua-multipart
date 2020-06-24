# lua-multipart [![Build Status](https://travis-ci.org/Kong/lua-multipart.svg)](https://travis-ci.org/Kong/lua-multipart)

A Lua library to parse and edit `multipart/form-data` data.

# Usage

```lua
local Multipart = require("multipart")

-- Initialize with a body
local multipart_data = Multipart(body, content_type_header)

-- Reading parameters
local parameter = multipart_data:get("param-name")

parameter.value -- The value
parameter.headers -- A table with the headers associated with the parameter

-- Reading all values of `files` part
local files = multipart_data:get_as_array("files")

-- Setting a new parameter
multipart_data:set_simple("some-param-name", "some-value")

-- Deleting a parameter
multipart_data:delete("param-name")

-- Setting a file
multipart_data:set_simple("name", "some-value", "filename", "content_type")

-- Get a multipart/form-data representation of the object
local body = multipart_data:tostring()

-- Get all the parameters in a Lua table, in the form of {param_name = param_value}
local t = multipart_data:get_all()

-- Get all the parameters in a Lua table, in the form of {param_name = param_value} where param_value is array
local t = multipart_data:get_all_as_arrays()

-- Get all the parameters in a Lua table, in the form of {param_name = param_value} where param_value is string or array
local t = multipart_data:get_all_with_arrays()
```

# Contribute

This library is a work in progress, pull-requests are welcomed.
