LUA_DIR=src/host/lua-5.1.4/src

SRC= src/host/*.c \
$(LUA_DIR)/lapi.c 		\
$(LUA_DIR)/lcode.c		\
$(LUA_DIR)/ldebug.c 	\
$(LUA_DIR)/ldump.c		\
$(LUA_DIR)/lgc.c			\
$(LUA_DIR)/liolib.c 	\
$(LUA_DIR)/lmathlib.c \
$(LUA_DIR)/loadlib.c	\
$(LUA_DIR)/lopcodes.c \
$(LUA_DIR)/lparser.c	\
$(LUA_DIR)/lstring.c	\
$(LUA_DIR)/ltable.c 	\
$(LUA_DIR)/ltm.c			\
$(LUA_DIR)/lvm.c			\
$(LUA_DIR)/lbaselib.c \
$(LUA_DIR)/ldblib.c 	\
$(LUA_DIR)/ldo.c			\
$(LUA_DIR)/lfunc.c		\
$(LUA_DIR)/linit.c		\
$(LUA_DIR)/llex.c 		\
$(LUA_DIR)/lmem.c 		\
$(LUA_DIR)/lobject.c	\
$(LUA_DIR)/loslib.c 	\
$(LUA_DIR)/lstate.c 	\
$(LUA_DIR)/lstrlib.c	\
$(LUA_DIR)/ltablib.c	\
$(LUA_DIR)/lundump.c	\
$(LUA_DIR)/lzio.c

PLATFORM= none
default: $(PLATFORM)

none:
	@echo "Please do"
	@echo "   nmake -f Bootstrap.mak windows"
	@echo "or"
	@echo "   CC=mingw32-gcc mingw32-make -f Bootstrap.mak mingw"
	@echo "or"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM"
	@echo "where HOST_PLATFORM is one of these:"
	@echo "   osx linux"

mingw: $(SRC)
	mkdir -p build/bootstrap
ifeq ($(BUILDHOST),linux)
	gcc -o build/bootstrap/premake5 -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" $? -lm
else
	$(CC) -o build/bootstrap/premake5 -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" $? -lole32
endif
	./build/bootstrap/premake5 embed
	./build/bootstrap/premake5 --os=windows --to=build/bootstrap $(PREMAKE_OPTS) gmake
	$(MAKE) -C build/bootstrap

macosx: osx
osx: $(SRC)
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake5 -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" -framework CoreServices $?
	./build/bootstrap/premake5 embed
	./build/bootstrap/premake5 --to=build/bootstrap $(PREMAKE_OPTS) gmake
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN`

linux: $(SRC)
	mkdir -p build/bootstrap
	$(CC) -o build/bootstrap/premake5 -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" $? -lm
	./build/bootstrap/premake5 embed
	./build/bootstrap/premake5 --to=build/bootstrap $(PREMAKE_OPTS) gmake
	$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN`

windows: $(SRC)
	if not exist build\bootstrap (mkdir build\bootstrap)
	cl /Fo.\build\bootstrap\ /Fe.\build\bootstrap\premake5.exe /DPREMAKE_NO_BUILTIN_SCRIPTS /I"$(LUA_DIR)" user32.lib ole32.lib $**
	.\build\bootstrap\premake5.exe embed
	.\build\bootstrap\premake5 --to=build/bootstrap $(PREMAKE_OPTS) vs2012
	devenv .\build\bootstrap\Premake5.sln /Upgrade
	devenv .\build\bootstrap\Premake5.sln /Build Release
