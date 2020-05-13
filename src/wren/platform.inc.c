#include "wrenapi.h"
#include <modules/platform.h>

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
