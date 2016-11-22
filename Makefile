ROOT_PATH		= .
OBJS_PATH		= ./objs
TARGET_PATH		= .
LUA_PATH		= $(ROOT_PATH)/srclib/lua51
HTTPD_PATH		= $(ROOT_PATH)/srclib/httpd

HTTPD_INC_PATH	= $(HTTPD_PATH)/include
HTTPD_LIB_PATH	= $(HTTPD_PATH)/lib
LUA_LIBNAME		= lua51.lib
LUAJIT_LIBNAME	= luajit51.lib

CPP		= cl.exe
CPP_PROJ= /nologo /MD /W3 /Zi /O2 /Oy- \
		  /I $(HTTPD_INC_PATH) /I $(LUA_PATH) \
		  /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "AP_LUA_DECLARE_EXPORT" \
		  /Fo"$(OBJS_PATH)\\" /Fd"$(OBJS_PATH)\mod_lua_src" /FD /c 

RSC		= rc.exe
RSC_PROJ= /l 0x409 /fo"$(OBJS_PATH)\mod_lua.res" \
		  /i $(HTTPD_INC_PATH) \
		  /d "NDEBUG" /d BIN_NAME="mod_lua.so" /d LONG_NAME="lua_module for Apache" 

LINK32	= link.exe
LINK32_FLAGS=\
		libapr-1.lib libaprutil-1.lib libhttpd.lib \
		kernel32.lib ws2_32.lib \
		/nologo /subsystem:windows \
		/dll \
		/incremental:no \
		/libpath:$(HTTPD_LIB_PATH) \
		/libpath:$(ROOT_PATH) 

RC_SOURCE = httpd.rc

LINK32_OBJS= \
	"$(OBJS_PATH)/lua_apr.obj" \
	"$(OBJS_PATH)/lua_config.obj" \
	"$(OBJS_PATH)/lua_passwd.obj" \
	"$(OBJS_PATH)/lua_request.obj" \
	"$(OBJS_PATH)/lua_vmprep.obj" \
	"$(OBJS_PATH)/mod_lua.obj" \
	"$(OBJS_PATH)/lua_dbd.obj" \
	"$(OBJS_PATH)/mod_lua.res"

all:$(OBJS_PATH) $(TARGET_PATH) \
	$(TARGET_PATH)/lua51.lib \
	$(TARGET_PATH)/luajit51.lib \
	$(TARGET_PATH)/mod_lua.so \
	$(TARGET_PATH)/mod_luajit.so

$(TARGET_PATH)/lua51.lib:
	cl /nologo /I $(LUA_PATH) /c /MD /O2 /Fo$(OBJS_PATH)/ $(LUA_PATH)\*.c 
	lib /nologo /out:lua51.lib $(OBJS_PATH)/*.obj

$(TARGET_PATH)/luajit51.lib:
	cd srclib/luajit51/src && cmd /c msvcbuild.bat
	cp -f srclib/luajit51/src/lua51.lib $(TARGET_PATH)/luajit51.lib

$(TARGET_PATH)/mod_lua.so:$(LINK32_OBJS) $(LUA_LIBNAME)
    $(LINK32) $(LINK32_FLAGS) \
		/pdb:"$(TARGET_PATH)/mod_lua.pdb" /debug \
		/out:"$(TARGET_PATH)/mod_lua.so" \
		/implib:"$(TARGET_PATH)/mod_lua.lib" \
		$(LUA_LIBNAME) $(LINK32_OBJS)

$(TARGET_PATH)/mod_luajit.so:$(LINK32_OBJS) $(LUAJIT_LIBNAME)
    $(LINK32) $(LINK32_FLAGS) \
		/pdb:"$(TARGET_PATH)/mod_luajit.pdb" /debug \
		/out:"$(TARGET_PATH)/mod_luajit.so" \
		/implib:"$(TARGET_PATH)/mod_luajit.lib" \
		$(LUAJIT_LIBNAME) $(LINK32_OBJS)

$(OBJS_PATH)/mod_lua.res:$(RC_SOURCE)
	$(RSC) $(RSC_PROJ) $(RC_SOURCE)

$(OBJS_PATH):
	mkdir.exe "$(OBJS_PATH)"

$(TARGET_PATH):
	mkdir.exe "$(TARGET_PATH)"

.c{$(OBJS_PATH)}.obj::
   $(CPP) $(CPP_PROJ) $< 

.cpp{$(OBJS_PATH)}.obj::
   $(CPP) $(CPP_PROJ) $< 

.cxx{$(OBJS_PATH)}.obj::
   $(CPP) $(CPP_PROJ) $< 

.c{$(OBJS_PATH)}.sbr::
   $(CPP) $(CPP_PROJ) $< 

.cpp{$(OBJS_PATH)}.sbr::
   $(CPP) 
   $(CPP_PROJ) $< 

.cxx{$(OBJS_PATH)}.sbr::
   $(CPP) $(CPP_PROJ) $< 

clean:
	rm -rf $(OBJS_PATH)
	rm -rf $(TARGET_PATH)/mod_lua.so
	rm -rf $(TARGET_PATH)/lua51.lib

