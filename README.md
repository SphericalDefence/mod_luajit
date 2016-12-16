# mod_luajit
Using luajit instead of lua for apache24 module mod_lua

## depends
- MS Build Tools 2015.3 (https://www.microsoft.com/en-us/download/details.aspx?id=48159)
- apache24 (httpd 2.4.23.0 windows vc14)
- lua-5.1.5.tar.gz
- LuaJIT-2.0.4.zip

## building
```sh
git clone git@github.com:buaabyl/mod_luajit.git
cd mod_luajit
nmake
```

then you have mod_lua.so and mod_luajit.so, copy to apache24's modules directory.

edit apache24's httpd.conf, add this line:
```
LoadModule lua_module modules/mod_luajit.so
```

and add this lines at the end of httpd.conf:
```
<Files "*.lua">
    SetHandler lua-script
</Files>

<Location /lua>
    DirectoryIndex index.lua
</Location>
```

create a 'lua' directory in htdocs, create a example file
```lua
-- example handler

require "string"

--[[
     This is the default method name for Lua handlers, see the optional
     function-name in the LuaMapHandler directive to choose a different
     entry point.
--]]
function handle(r)
    r.content_type = "text/plain"

    if r.method == 'GET' then
        if jit == nil then
            jitinfo = "nojit"
        else
            jitinfo = jit.version
        end
        r:puts("Hello Lua World!" .. _VERSION .. "/" .. jitinfo .. "\n")
        for k, v in pairs( r:parseargs() ) do
            r:puts( string.format("%s: %s\n", k, v) )
        end
    elseif r.method == 'POST' then
        r:puts("Hello Lua World!\n")
        for k, v in pairs( r:parsebody() ) do
            r:puts( string.format("%s: %s\n", k, v) )
        end
    elseif r.method == 'PUT' then
-- use our own Error contents
        r:puts("Unsupported HTTP method " .. r.method)
        r.status = 405
        return apache2.OK
    else
-- use the ErrorDocument
        return 501
    end
    return apache2.OK
end
```

open you browser http://127.0.0.1/lua/ it will show:
```
Hello Lua World!Lua 5.1/LuaJIT 2.0.4
```

