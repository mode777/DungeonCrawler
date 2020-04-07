LIBFLAGS_WIN32=-L./lib -l:libGLESv2.lib -l:libEGL.lib -l:SDL2.dll
#LIBFLAGS_WIN32=-L./lib -l:libGLESv2.dll -l:libEGL.dll -l:SDL2.dll
LIBFLAGS_RPI=-L/opt/vc/lib -lbrcmEGL -lbrcmGLESv2 -lm -L/usr/lib/arm-linux-gnueabihf -lSDL2

INCLUDES_COMMON= -I./include/common -I./wren/src/include
INCLUDES_WIN32= -I./include/win32
INCLUDES_WEB= -I./include/web
INCLUDES_RPI= -I./include/rpi
INCLUDES_HEADERS= -I./headers

main: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_RPI) $(INCLUDES_HEADERS) 
main.exe: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_WIN32) $(INCLUDES_HEADERS) 
main.wasm: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_WEB) $(INCLUDES_HEADERS) 

VPATH = ./src ./src/platform ./src/image ./src/gl ./src/gltf ./src/renderer3d ./src/wren ./wren/src/vm ./src/json

CORE= common.o
MOD_PLATFORM= platform.o egl.o file.o
MOD_GL= util.o shader.o geometry.o
MOD_IMAGE= image.o
MOD_GLTF= gltf.o
MOD_RENDERER3D= renderer3d.o transform.o
MOD_WREN= wren.o api.o wren_compiler.o wren_core.o wren_debug.o wren_primitive.o wren_utils.o wren_value.o wren_vm.o
MOD_JSON= json.o

OBJECTS= main.o $(CORE) $(MOD_PLATFORM) $(MOD_GL) $(MOD_IMAGE) $(MOD_RENDERER3D) $(MOD_WREN) $(MOD_JSON)
OBJECTS_WASM = $(OBJECTS:.o=.bc)

# main: main.o pgl.so
# 	gcc -o main main.o -L. -l:pgl.so $(LIBFLAGS_RPI) -Wl,-R -Wl,/home/pi/repos/pgl/native
# 	cp main ../bin

main: $(OBJECTS)
	gcc -o $@ $(OBJECTS) $(LIBFLAGS_RPI)

main.exe: $(OBJECTS)
	gcc -o $@ $(OBJECTS) $(LIBFLAGS_WIN32)

main.wasm: $(OBJECTS_WASM)
	emcc -o main.html $(OBJECTS_WASM) -s WASM=1 -s USE_SDL=2 -s ALLOW_MEMORY_GROWTH=1 --shell-file html/template.html --preload-file shaders --preload-file scripts --preload-file assets --preload-file main.wren

%.o: %.c
	gcc -O2 -Wall -o $@ -c $< -fPIC $(INCLUDEFLAGS)

%.bc: %.c
	emcc -O2 -Wall -o $@ -c $< -fPIC $(INCLUDEFLAGS)

clean:
	rm -f *.{o,dll,so,bc,exe}