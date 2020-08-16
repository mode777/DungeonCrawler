LIBFLAGS_WIN32=-L./lib -l:libGLESv2.lib -l:libEGL.lib -l:SDL2.dll
#LIBFLAGS_WIN32=-L./lib -l:libGLESv2.dll -l:libEGL.dll -l:SDL2.dll
LIBFLAGS_RPI=-L/opt/vc/lib -lbrcmEGL -lbrcmGLESv2 -lm -L/usr/lib/arm-linux-gnueabihf -lSDL2
LIBFLAGS_LINUX=-lSDL2 -lm -ldl -L./linux64 -l:libEGL.so -l:libGLESv2.so

FLAGS=-O3 -Wall 
#FLAGS=-DDEBUG -O3 -Wall 

INCLUDES_COMMON= -I./include/common -I./wren/src/include -I./wren/src/optional -I./wren/src/vm
INCLUDES_WIN32= -I./include/win32
INCLUDES_WEB= -I./include/web
INCLUDES_RPI= -I./include/rpi
INCLUDES_HEADERS= -I./headers

main-rpi: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_RPI) $(INCLUDES_HEADERS) 
main-linux: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_RPI) $(INCLUDES_HEADERS) 
main.exe: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_WIN32) $(INCLUDES_HEADERS) 
main.wasm: INCLUDEFLAGS= $(INCLUDES_COMMON) $(INCLUDES_WEB) $(INCLUDES_HEADERS) 

VPATH = ./src ./src/platform ./src/image ./src/gl ./src/gltf ./src/renderer3d ./src/wren ./wren/src/optional ./wren/src/vm ./src/json ./src/memory ./src/math

CORE= common.o
MOD_PLATFORM= platform.o egl.o file.o
MOD_GL= util.o shader.o geometry.o
MOD_IMAGE= image.o
MOD_GLTF= gltf.o
MOD_RENDERER3D= renderer3d.o
MOD_WREN= wren.o api.o wren_compiler.o wren_core.o wren_debug.o wren_primitive.o wren_utils.o wren_value.o wren_vm.o wren_opt_meta.o wren_opt_random.o
MOD_JSON= json.o
MOD_MEMORY= memory.o
MOD_MATH = noise.o

OBJECTS= main.o $(CORE) $(MOD_PLATFORM) $(MOD_GL) $(MOD_IMAGE) $(MOD_RENDERER3D) $(MOD_WREN) $(MOD_JSON) $(MOD_MEMORY) $(MOD_MATH)
OBJECTS_WASM = $(OBJECTS:.o=.bc)

# main: main.o pgl.so
# 	gcc -o main main.o -L. -l:pgl.so $(LIBFLAGS_RPI) -Wl,-R -Wl,/home/pi/repos/pgl/native
# 	cp main ../bin

main-rpi: $(OBJECTS)
	gcc -o $@ $(OBJECTS) $(LIBFLAGS_RPI)

main-linux: $(OBJECTS)
	gcc -o $@ $(OBJECTS) $(LIBFLAGS_LINUX)

main.exe: $(OBJECTS)
	gcc -o $@ $(OBJECTS) $(LIBFLAGS_WIN32)

main.wasm: $(OBJECTS_WASM)
	emcc -o main.html $(OBJECTS_WASM) -s WASM=1 -s USE_SDL=2 -s --shell-file html/template.html --preload-file shaders --preload-file scripts --preload-file assets --preload-file game --preload-file main.wren -s ALLOW_MEMORY_GROWTH=1

%.o: %.c
	gcc -o $@ -c $< -fPIC $(INCLUDEFLAGS) $(FLAGS)

api.o: api.c graphics.inc.c image.inc.c io.inc.c json.inc.c math.inc.c memory.inc.c platform.inc.c renderer.inc.c 
	gcc -o $@ -c $< -fPIC $(INCLUDEFLAGS) $(FLAGS)

api.bc: api.c graphics.inc.c image.inc.c io.inc.c json.inc.c math.inc.c memory.inc.c platform.inc.c renderer.inc.c 
	emcc -o $@ -c $< -fPIC $(INCLUDEFLAGS) $(FLAGS)

%.bc: %.c
	emcc -o $@ -c $< -fPIC $(INCLUDEFLAGS) $(FLAGS)

clean:
	rm -f *.{o,dll,so,bc,exe}
	rm -f *.o
	rm -f main-linux
	rm -f main-rpi