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

# Reading every part

`get_parts()` returns every part of the decoded body, in the order of the body. It includes the parts that have no `name` in their `Content-Disposition` header, for example the parts of a `multipart/mixed` body. The other getters do not return these parts.

```lua
for _, part in ipairs(multipart_data:get_parts()) do
  part.name -- nil when the part has no name
  part.value -- the value of the part
  part.headers -- a list of { name = "content-type", value = "application/json" } in body order
end
```

The header list keeps duplicate headers. Header names are in lower case.

`get_parts()` describes the body as the library decoded it. A later call to `set_simple` or `delete` does not change the result.

# Decoding rules

- The library ignores the text before the first delimiter.
- The library decodes the parts that follow a closing delimiter, as version 0.5 did.
- A delimiter line is `--<boundary>` or `--<boundary>--`, optionally followed by spaces or tabs.
- The `boundary` and `name` parameters can be quoted. A quoted value can contain `;` and an escaped quote.
- The name of the parameter is not case-sensitive.
- If the closing delimiter is missing, the library keeps the last part.

# Contribute

This library is a work in progress, pull-requests are welcomed.
