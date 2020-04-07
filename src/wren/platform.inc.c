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