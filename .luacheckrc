std             = "ngx_lua"
unused_args     = false
redefined       = false
max_line_length = false


globals = {
    "_KONG",
    "kong",
    "ngx.IS_CLI",
    "kprof",
    "ngx.worker.pids",
}


not_globals = {
    "string.len",
    "table.getn",
}


ignore = {
    "6.", -- ignore whitespace warnings
}


exclude_files = {
    ".git",
    "spec/fixtures/invalid-module.lua",
    "spec-old-api/fixtures/invalid-module.lua",
    "pgmoon/",
    "bazel-bin",
    "bazel-out",
    "bazel-kong-ee",
    "kong/resty/kafka/",
}

files["kong/tools/sandbox/kong.lua"] = {
     read_globals = {
        "_ENV",
        "table.pack",
        "table.unpack",
     }
}


files["kong/hooks.lua"] = {
    read_globals = {
        "table.pack",
        "table.unpack",
    }
}


files["kong/db/schema/entities/workspaces.lua"] = {
    read_globals = {
        "table.unpack",
    }
}


files["kong/plugins/ldap-auth/*.lua"] = {
    read_globals = {
        "bit.mod",
        "string.pack",
        "string.unpack",
    },
}


files["spec/**/*.lua"] = {
    std = "ngx_lua+busted",
}

files["**/*_test.lua"] = {
    std = "ngx_lua+busted",
}

files["spec-old-api/**/*.lua"] = {
    std = "ngx_lua+busted",
}

files["spec-ee/**/*.lua"] = {
    std = "ngx_lua+busted",
}

files["kong/keyring/init.lua"] = {
    read_globals = {
        "table.pack",
        "table.unpack",
    }
}

files["kong/hooks.lua"] = {
    read_globals = {
        "table.pack",
        "table.unpack",
    }
}

files["spec-ee/01-unit/07-keyring/01-init_spec.lua"] = {
    read_globals = {
        "table.pack",
    }
}

files["scripts/tools/*.lua"] = {
    read_globals = {
        "args",
    }
}

files["spec-ee/01-unit/09-jwe/01-jwe_spec.lua"] = {
    read_globals = {
        "table.unpack",
    }
}

files["spec-ee/02-integration/25-kafka/helpers.lua"] = {
    read_globals = {
        "table.unpack",
    },
}
