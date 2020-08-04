#include <modules/platform.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>
#include <SDL2/SDL_syswm.h>
#ifdef EMSCRIPTEN
#include <emscripten/emscripten.h>
#endif

#include "egl.h"

#if defined(__arm__) && defined(__unix__)
#define WIDTH 1920
#define HEIGHT 1080
#else
#define WIDTH 1280
#define HEIGHT 720
#endif

const static PGLWindowConfig defaults = {
  .width = WIDTH,
  .height = HEIGHT,
  .title = "GameWindow"
};

static PGLWindowConfig windowConfig;
static PGLWindow* activeWindow;

inline void pglDestroyWindow(PGLWindow* win){
	SDL_DestroyWindow(win->handle);
  free(win);
}

void pglPlatformInit(){
  windowConfig = defaults;
  SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
}

void pglWindowConfig(PGLWindowConfig* config){
  windowConfig.height = config->height != 0 ? config->height : windowConfig.height;
  windowConfig.width = config->width != 0 ? config->width : windowConfig.width;
  windowConfig.title = config->title != NULL ? config->title : windowConfig.title;
}



PGLWindow* pglCreateWindow() {
  SDL_Window *window;                    // Declare a pointer

  // Create an application window with the following settings:
  window = SDL_CreateWindow(
      windowConfig.title,                  // window title
      SDL_WINDOWPOS_UNDEFINED,           // initial x position
      SDL_WINDOWPOS_UNDEFINED,           // initial y position
      windowConfig.width,                               // width, in pixels
      windowConfig.height,                               // height, in pixels
      SDL_WINDOW_SHOWN                  // flags - see below
  );

  // Check that the window was successfully created
  if (window == NULL) {
      // In the case that the window could not be made...
      pglLog(PGL_MODULE_PLATFORM, PGL_LOG_ERROR, "Could not create window: %s", SDL_GetError());
      return NULL;
  }
  else {
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_INFO, "Window sucessfully created (%i, %i)", windowConfig.width, windowConfig.height);
  }

  SDL_SysWMinfo systemInfo; 
  SDL_VERSION(&systemInfo.version);
  SDL_GetWindowWMInfo(window, &systemInfo);

  PGLWindow* pglWindow = calloc(1, sizeof(PGLWindow));
  pglWindow->handle = window;
  pglWindow->width = windowConfig.width;
  pglWindow->height = windowConfig.height;

  #if defined(PGL_PLATFORM_RPI) || defined (EMSCRIPTEN)
  // raspberry
  initEgl(NULL);
  #elif defined(PGL_PLATFORM_LINUX)
  initEgl(systemInfo.info.x11.window);
  #elif defined(PGL_PLATFORM_WIN)
  initEgl(systemInfo.info.win.window);
  #endif

  activeWindow = pglWindow;
  return pglWindow;
}

PGLPlatformCallbacks platform;

void pglRegisterCallbacks(PGLPlatformCallbacks* callbacks){
  platform = *callbacks;
}

SDL_bool quit = SDL_FALSE;
Uint64 now = 0;
Uint64 last = 0;
double delta = 0;

static void platform_update(){
  last = now;
  now = SDL_GetPerformanceCounter();
  delta = (double)((now - last) / (double)SDL_GetPerformanceFrequency() );
  
  if(platform.update != NULL){
    (*platform.update)(delta);
  }
}

#ifndef EMSCRIPTEN 
void pglRun() { 
  while (!quit)
  {
    platform_update();    
  }
}
#else
void pglRun() {
  emscripten_set_main_loop(
    platform_update,  // function to call
    0,         // frame rate (0 = browser figures it out)
    1          // simulate infinite loop
  );
}
#endif

bool pglIsKeyDown(const char* key){
  const Uint8 *state = SDL_GetKeyboardState(NULL);
  SDL_Scancode code = SDL_GetScancodeFromName(key);

  if(code == SDL_SCANCODE_UNKNOWN){
    pglLog(PGL_MODULE_PLATFORM, PGL_LOG_WARNING, "Unknown key %s", key);
    return false;
  }

  return state[code];
}

PGLMousePos pglGetMousePosition(){
  PGLMousePos pos;
  SDL_GetMouseState(&pos.x, &pos.y);
  return pos;
}

void pglSetMousePosition(int x, int y){
  SDL_WarpMouseInWindow(activeWindow->handle, x,y);
}

void pglQuit(){
  quit = SDL_TRUE;
}

