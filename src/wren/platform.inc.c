#include "wrenapi.h"
#include <modules/platform.h>
#include <modules/pgl_wren.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>

static SDL_Event event;

void Keyboard_isDown_1(WrenVM* vm){
  const char* key = wrenGetSlotString(vm, 1);
  bool result = pglIsKeyDown(key);
  wrenSetSlotBool(vm, 0, result);
}

void Window_config_3(WrenVM* vm){
  PGLWindowConfig win = {0};
  win.width = (size_t)wrenGetSlotDouble(vm, 1);
  win.height = (size_t)wrenGetSlotDouble(vm, 2);
  win.title = wrenGetSlotString(vm, 3);
  pglWindowConfig(&win);
}



void Application_logLevel_1(WrenVM* vm){
  int sev = (int)wrenGetSlotDouble(vm,1);
  pglLogLevel(sev);
}

void Application_logLevel_2(WrenVM* vm){
  int mod = (int)wrenGetSlotDouble(vm,1);
  int sev = (int)wrenGetSlotDouble(vm,2);
  pglLogModLevel(mod, sev);
}

void Application_pollEvent_1(WrenVM* vm){
  bool success = SDL_PollEvent(&event);
  if(!success){
    wrenSetSlotBool(vm, 0, false);
    return;
  }
  wrenSetSlotDouble(vm, 0, (double)event.type);
  wrenSetListElement(vm, 1, 0, 0);
  switch(event.type){
    case SDL_MOUSEMOTION: 
      wrenSetSlotDouble(vm, 0, (double)event.motion.x);
      wrenSetListElement(vm, 1 ,1 ,0);
      wrenSetSlotDouble(vm, 0, (double)event.motion.y);
      wrenSetListElement(vm, 1 ,2 ,0);
      break;
    case SDL_MOUSEBUTTONDOWN:
    case SDL_MOUSEBUTTONUP:
      wrenSetSlotDouble(vm, 0, (double)event.button.button);
      wrenSetListElement(vm, 1, 1, 0);
      wrenSetSlotDouble(vm, 0, (double)event.button.clicks);
      wrenSetListElement(vm, 1, 2, 0);
      break;
    case SDL_KEYDOWN: 
    case SDL_KEYUP:
      wrenSetSlotString(vm, 0, SDL_GetKeyName(event.key.keysym.sym));
      wrenSetListElement(vm, 1, 1, 0);
      wrenSetSlotBool(vm, 0, event.key.repeat);
      wrenSetListElement(vm, 1, 2, 0);
      break;
    case SDL_TEXTINPUT:
      wrenSetSlotString(vm, 0, event.text.text);
      wrenSetListElement(vm, 1, 1, 0);
  }
  wrenSetSlotBool(vm, 0, true);
}

void Application_loadModule_2(WrenVM* vm){
  const char* module = wrenGetSlotString(vm, 1);
  const char* path = wrenGetSlotString(vm, 2);

  bool res = pglRunWrenFile(module, path);

  if(!res)
    pgl_wren_runtime_error(vm, "Module not found");
}

void Application_quit_0(WrenVM* vm){
  pglQuit();
}

void Mouse_getPosition_1(WrenVM* vm){
  PGLMousePos mouse = pglGetMousePosition();
  wrenSetSlotDouble(vm, 0, (double)mouse.x);
  wrenSetListElement(vm, 1, 0, 0);
  wrenSetSlotDouble(vm, 0, (double)mouse.y);
  wrenSetListElement(vm, 1, 1, 0);
}

void Mouse_setPosition_2(WrenVM* vm){
  int x = (int)wrenGetSlotDouble(vm, 1);
  int y = (int)wrenGetSlotDouble(vm, 2);
  pglSetMousePosition(x,y);
}
